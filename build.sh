#!/bin/bash

for d in 01-semik-debian 02-semik-nginx 03-semik-counter; do
    echo ">>> Building in $d"
    t=`echo $d | sed "s/^[0-9][0-9]-//" | tr '[:upper:]' '[:lower:]'`
    podman build -t "$t" "$d"
done