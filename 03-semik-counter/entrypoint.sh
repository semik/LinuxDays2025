#!/bin/sh
trap 'kill $HTTPD_PID; exit' TERM INT

busybox httpd -vv -f -p 8080 -h /app &
HTTPD_PID=$!
wait $HTTPD_PID