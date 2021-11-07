
# Sandboxes

## Sandbox_1  
* Fluentd, with metrics.
* Fluentd received Apache logs and outputs to stdout.

## Sandbox_2 : 
* Fluentd, with metrics, Splunk
* Fluentd received Apache logs parses source and send to Splunk.
* Fluentd sets source and sourcetype based on docker tags. 

## Sandbox_3 : 
* Fluentd, with metrics. Splunk
* Fluentd received Apache logs parses source and send to Splunk.
* Fluentd sets index, source and sourcetype based on docker tags. 

## Sandbox_4 : 
* Logstash, Splunk
* Logstash reads a static file with example ALB logs and parses into json.
* Logs are sent to Splunk, as JSON, using the RAW endpoint.

## Sandbox_5 : 
* Logstash, Splunk
* Logstash reads a static file with example ALB logs and parses into json.
* Logstash sets a hard-coded value for index and sourcetype
* Logs are sent to Splunk, as 'events', using the event endpoint.

## Sandbox_6 : 
* Logstash, Splunk
* A script generates sample HTTPS ALB logs and feeds them to logstash.
* Logstash sets the source to match the loadbalancer. 
* Sourcetype is hardcoded to JSON. 
* Logs are sent to Splunk, as 'events', using the event endpoint.

## Sandbox_7 : 
* Logstash, Splunk
* A script generates sample HTTPS ALB logs and feeds them to logstash.
* Logstash masks passwords in the URI and drops Healthchecks that return 200s.
* Logstash sets the source to match the loadbalancer. 
* Sourcetype is hardcoded to JSON. 

## Sandbox_8 : 
* Logstash, Splunk

 This uses the Splunk HEC event to set the index and sourcetype. Splunk does all the field extractions based on the source type.

## Sandbox_9 : 
* Logstash, Splunk

This is a more complete example. It masks senstive fields, drops Healthchecks logs that are successful. It then create a copies of the log, each of which can be parsed separately. 

One is parsed to goto Splunk. The log line is sent as an event. The index is dynamically set based on log the ALB name. The sourcetype is set to a custom sourcetype. The custom sourcetype is defined in Splunk and used to break out the fields.

The second copy of the log is left as is and sent to sent to stdout. It could instead send it to a remote loghost, Elasticsearch, Kafka or some other sink.

