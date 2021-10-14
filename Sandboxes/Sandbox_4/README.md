
# Description

This Sandbox runs two docker containers: Logstash and Splunk. The purpose is to simulate
and provide a place to test receiving AWS ALB logs, parsing them into JSON and then
forwarding them to Splunk, via HEC.

The current config has a static logfile with example ALB logs taken from AWS documentation. Logstash
reads the contents of the file, breaks it out into JSON and then forwards to Splunk.


# Usage

1. `docker compose up -d`
2. Log into Splunk UI on the host browser. `https://localhost:8000` 
* username = admin, password=adminadmin
3. Search `index=main` for `alltime` and you should see some ALB logs.

# Example

`wss 2021-10-13T13:04:00.186641Z app/my-loadbalancer/50dc6c495c0c9188 10.0.0.140:44244 10.0.0.171:8010 0.000 0.001 0.000 101 101 218 786 "GET https://10.0.0.30:443/ HTTP/1.1" "-" ECDHE-RSA-AES128-GCM-SHA256 TLSv1.2 arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-targets/73e2d6bc24d8a067 "Root=1-58337364-23a8c76965a2ef7629b185e3" "-" "-" 1 2018-07-02T22:22:48.364000Z "forward" "-" "-" 10.0.0.171:8010 101 "-" "-"` 

gets parsed into the below and shows up in Splunk with those fields.

```{
            "target_group_arn" => "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-targets/73e2d6bc24d8a067",
                     "request" => "https://10.0.0.30:443/",
              "received_bytes" => 218,
    "response_processing_time" => 0.0,
                 "client_port" => 44244,
             "elb_status_code" => 101,
               "RequestDomain" => "-",
                "error_reason" => "-",
                   "timestamp" => "2021-10-13T13:04:00.186641Z",
                "loadbalancer" => "app/my-loadbalancer/50dc6c495c0c9188",
                    "trace_id" => "Root=1-58337364-23a8c76965a2ef7629b185e3",
                "ssl_protocol" => "TLSv1.2",
                  "backend_ip" => "10.0.0.171",
                "backend_port" => 8010,
                        "type" => "wss",
         "backend_status_code" => 101,
             "chosen_cert_arn" => "-",
       "request_creation_time" => "2018-07-02T22:22:48.364000Z",
                        "path" => "/logs/elb",
             "action_executed" => "forward",
                  "sent_bytes" => 786,
                        "verb" => "GET",
                 "httpversion" => "1.1",
     "backend_processing_time" => 0.001,
       "matched_rule_priority" => 1,
                   "client_ip" => "10.0.0.140",
                        "host" => "454df8e639d6",
     "request_processing_time" => 0.0,
                   "userAgent" => "-",
                  "ssl_cipher" => "ECDHE-RSA-AES128-GCM-SHA256",
                "redirect_url" => "-\" \"-\" 10.0.0.171:8010 101 \"-"
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
