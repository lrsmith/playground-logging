#!/bin/ash 

# Generate Apache logs every 10 seconds

while true
do

ts=`date "+%d/%h/%Y:%H:%M:%S %z"`
ts2=`date "+%a %b %d %H:%M:%S %Y"`

# Generate apache2 access log to stdout
echo "192.168.2.20 - - [$ts] \"GET /cgi-bin/try/ HTTP/1.0\" 200 3395 \"http://localhost/\" \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36\"" > /dev/stdout

# Generate apache error log to stderr
echo "[$ts2] [error] [client 1.2.3.4] Directory index forbidden by rule: /apache/web-data/test2" > /dev/stderr

sleep 10
done
