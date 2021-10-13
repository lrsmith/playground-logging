
# Description

Simulate an Apache container outputting access logs to stdout and error logs to stderr.
The logs are sent to fluentd, which then sends the raw logs to Splunk, via HEC. Fluentd
specifies the index, source and sourcetype based on the logs.



# Adding self-signed cert
echo "" | openssl s_client -showcerts -connect localhost:8088 -prexit 2>/dev/null \
| sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p' > /tmp/cert.pem > /tmp/cert.pem

./jdk/bin/keytool -import -file /tmp/cert.pem -keystore /tmp/logstash.keystore
./jdk/bin/keytool -import -file /tmp/cert.pem -keystore jdk/lib/security/cacerts

# Reference

* curl http://localhost:24231/metrics | grep -v "^#"  | grep splunk


# Troubleshooting

docker run -it --entrypoint bash --network logging docker.elastic.co/logstash/logstash-oss:7.15.0

# Setup

docker run --rm -it splunk/splunk:8.2 create-defaults > config/splunk/defaults.yml
# Set HEC SSL to false


