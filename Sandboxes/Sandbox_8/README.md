
# Description

This Sandbox runs two docker containers: Logstash and Splunk. The purpose is to simulate
and provide a place to test receiving Apache access_combined logs. The logs are not parsed
but is passed as an event and the sourcetype is set, to let Splunk do the field extraction.

For this sandbox the index is hard-coded, but it could be parsed from the logs and set
dynamically.

This sandbox example also replaces passwords.

A script `logs/generate-https-log.sh` is used to generate Apache access_combined logs setting 
the date to the current time, and randomly setting the last two octets of the client IP.

# Usage

1. `docker compose up -d`
2. Log into Splunk UI on the host browser. `https://localhost:8000` 
* username = admin, password=adminadmin
3. Generate logs `cd logs && ./generate-https-logs.sh`
4. Search in Splunk 

# Example

```logstash  | {
logstash  |           "host" => "1eff6a16d82f",
logstash  |          "event" => "10.1.7.2 - webdev [03/Nov/2021:07:58:45 -0700] \"GET /login?password=********* HTTP/1.0\" 200 0442 \"-\" \"check_http/1.10 (nagios-plugins 1.4)\"",
logstash  |     "sourcetype" => "access_combined",
logstash  |          "index" => "ford"
logstash  | }```

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
