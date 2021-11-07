#!/bin/sh

#2021-10-13T13:02:00.186641Z
#2021-11-03T00:36:07Z


domains=(zaphod ford trillian marvin arthur slartibartfast)
uri=( "login?user=${domains[$((1 + $RANDOM % 5))]}" "" "login?password=1234" "login?user=${domains[$((1 + $RANDOM % 5))]}&password=1234abcd" "api/health" "login?password=1234abcd&user=${domains[$((1 + $RANDOM % 5))]}")
elb_status=( 200 302 400 401 404 500 )

while true
do
date=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

echo "https $date app/my-loadbalancer/50dc6c495c0c9188 192.168.131.$((1 + $RANDOM % 10)):2817 10.0.0.$((1 + $RANDOM % 10)):80 0.086 0.048 0.037 ${elb_status[$((1 + $RANDOM % 5))]} 200 0 57 \"GET https://${domains[$((1 + $RANDOM % 5))]}.com:443/${uri[$((1 + $RANDOM % 6))]} HTTP/1.1\" \"curl/7.46.0\" ECDHE-RSA-AES128-GCM-SHA256 TLSv1.2 arn:aws:elasticloadbalancing:us-east-2:123456789012:targetgroup/my-targets/73e2d6bc24d8a067 \"Root=1-58337281-1d84f3d73c47ec4e58577259\" \"${domains[$((1 + $RANDOM % 5))]}.com\" \"arn:aws:acm:us-east-2:123456789012:certificate/12345678-1234-1234-1234-123456789012\" 1 $date \"authenticate,forward\" \"-\" \"-\" 10.0.0.1:80 200 \"-\" \"-\"" >> ./elb

echo "https $date app/my-loadbalancer/50dc6c495c0c9188 192.168.131.$((1 + $RANDOM % 10)):2817 10.0.0.$((1 + $RANDOM % 10)):80 0.086 0.048 0.037 ${elb_status[$((1 + $RANDOM % 5))]} 200 0 57 \"GET https://${domains[$((1 + $RANDOM % 5))]}.com:443/${uri[$((1 + $RANDOM % 6))]} HTTP/1.1\" \"ELB-HealthChecker/2.0\" ECDHE-RSA-AES128-GCM-SHA256 TLSv1.2 arn:aws:elasticloadbalancing:us-east-2:123456789012:targetgroup/my-targets/73e2d6bc24d8a067 \"Root=1-58337281-1d84f3d73c47ec4e58577259\" \"${domains[$((1 + $RANDOM % 5))]}.com\" \"arn:aws:acm:us-east-2:123456789012:certificate/12345678-1234-1234-1234-123456789012\" 1 $date \"authenticate,forward\" \"-\" \"-\" 10.0.0.1:80 200 \"-\" \"-\"" >> ./elb


done

