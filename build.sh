#!/bin/bash

for d in 01-semik-debian 02-semik-nginx 03-semik-counter; do
    echo ">>> Building in $d"
    t=`echo $d | sed "s/^[0-9][0-9]-//" | tr '[:upper:]' '[:lower:]'`
    podman build -t "$t" "$d"
done

podman tag semik-nginx semik75/ld25-nginx:latest
podman tag semik-counter semik75/ld25-counter:latest

podman push semik75/ld25-nginx:latest
podman push semik75/ld25-counter:latest