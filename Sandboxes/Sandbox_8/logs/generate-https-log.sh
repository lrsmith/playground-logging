#!/bin/sh

while true
do

ts=`date "+%d/%h/%Y:%H:%M:%S %z"`

echo "10.1.$((1 + $RANDOM % 10)).$((1 + $RANDOM % 10)) - webdev [$ts] \"GET / HTTP/1.0\" 200 0442 \"-\" \"check_http/1.10 (nagios-plugins 1.4)\"" >> ./elb

sleep 1
done



