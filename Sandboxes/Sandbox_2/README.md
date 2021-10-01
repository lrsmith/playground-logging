
# Description

Simulate an Apache container outputting access logs to stdout and error logs to stderr.
The logs are sent to fluentd, which then sends the raw logs to Splunk, via HEC. Fluentd
specifies the index, source and sourcetype based on the logs.





# Reference

* curl http://localhost:24231/metrics | grep -v "^#"  | grep splunk
