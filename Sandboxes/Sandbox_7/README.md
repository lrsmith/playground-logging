
# Description

This Sandbox runs two docker containers: Logstash and Splunk. The purpose is to simulate
and provide a place to test receiving AWS ALB logs, parsing them into JSON and then
forwarding them to Splunk, via HEC. 

Logstash 
* Parses the RequestDomain and uses that the determine which index to send the logs to.
* Passwords in the request field are replaced with '*'.
* Sourcetype is hard-coded to aws:alb:accesslogs.
* Health checks that return a 200 get dropped

A new script `logs/generate-https-log.sh` is used to generate HTTPS ALB logs setting the date to the 
current time, and randomly setting the domain in various fields.

# Usage

1. `docker compose up -d`
2. Log into Splunk UI on the host browser. `https://localhost:8000` 
* username = admin, password=adminadmin
3. Generate logs `cd logs && ./generate-https-logs.sh`
4. Search in Splunk 

# Example

```{
         "event" => {
                 "elb_status_code" => 200,
                            "type" => "https",
                      "ssl_cipher" => "ECDHE-RSA-AES128-GCM-SHA256",
         "request_processing_time" => 0.086,
                     "client_port" => 2817,
                         "request" => "https://marvin.com:443/login?password=*********",
                "target_group_arn" => "arn:aws:elasticloadbalancing:us-east-2:123456789012:targetgroup/my-targets/73e2d6bc24d8a067",
                     "httpversion" => "1.1",
                    "ssl_protocol" => "TLSv1.2",
        "response_processing_time" => 0.037,
                 "chosen_cert_arn" => "arn:aws:acm:us-east-2:123456789012:certificate/12345678-1234-1234-1234-123456789012",
                       "timestamp" => "2021-11-03T05:08:14Z",
           "matched_rule_priority" => 1,
                   "RequestDomain" => "slartibartfast.com",
           "request_creation_time" => "2021-11-03T05:08:14Z",
                    "loadbalancer" => "app/my-loadbalancer/50dc6c495c0c9188",
                      "sent_bytes" => 57,
                 "action_executed" => "authenticate,forward",
                  "received_bytes" => 0,
             "backend_status_code" => 200,
                    "error_reason" => "-",
                    "redirect_url" => "-\" \"-\" 10.0.0.1:80 200 \"-",
         "backend_processing_time" => 0.048,
                            "verb" => "GET",
                    "backend_port" => 80,
                        "trace_id" => "Root=1-58337281-1d84f3d73c47ec4e58577259",
                       "client_ip" => "192.168.131.4",
                      "backend_ip" => "10.0.0.6",
                       "userAgent" => "curl/7.46.0"
    },
          "host" => "app/my-loadbalancer/50dc6c495c0c9188",
    "sourcetype" => "aws::alb::accesslogs",
         "index" => "slartibartfast",
        "source" => "4d6a4eec77f3"
}```


# Troubleshooting

`docker run -it --entrypoint bash --network logging docker.elastic.co/logstash/logstash-oss:7.15.0`

# Setup Notes

## Splunk Docker Configuration

Splunk provides a Docker container that can be used for testing and development. The container
runs ansible to initially configure the container. It is possible to adjust what Ansible
does by providing a Yaml file.

The command `docker run --rm -it splunk/splunk:8.2 create-defaults > config/splunk/defaults.yml`
can be run to generate the default Yaml file that ansible uses. The output can then be modified
and mounted in the container to be used by Ansible at Docker creation time.

For this Sandbox the configuration is modified to set HEC to use SSL false. This was done
to simplify testing. Logstash's HTTP output will not trust the self-signed cert. The
cert would need to be uploaded into a Keystore for Logstash to trust it, and the hostnames
would need to match. ( See notes below on the start of that for a future Sandbox )


## Logstash HTTP Output using SSL and Self Signed Certs

The Logstash HTTP Output does not support disabling SSL verification, and will fail when
talking to HEC if it uses a self-signed cert and the hostname used does not match the
SSL cert subject.

Below are the steps which can be used to import the Splunk HEC SSL cert so that Logstash
will trust the cert. This is currently a WIP.

1. Get the SSL cert and chain from Splunk. Note: This was done on the host running the Splunk container

```echo "" | openssl s_client -showcerts -connect localhost:8088 -prexit 2>/dev/null \
| sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p' > /tmp/cert.pem```

2. Copy `/tmp/cert.pem` onto the running logstash container
3. Load the cert into the JDK Keystore Note: This is done on the logstash container.  `./jdk/bin/keytool -import -file /tmp/cert.pem -keystore jdk/lib/security/cacerts` Note: The default password is `changeit` and type `yes` when asked to trust the cert
4. TBD: The cert subject name does not currently match the container. Need to finish documenting that work and automate the above.

# References
* AWS ALB Logs - Documentation and example logs. https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html

# To Do

1. Finish documenting and automating how to use SSL for HEC
2. Writ script to continually generate ALB logs for ingestion.
3. Need to remove a few default fields from the JSON
4. Investigate being able to adjust the source and host, as it shows up in Splunk
