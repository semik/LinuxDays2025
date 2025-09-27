#!/bin/bash

for d in 01-container-from-scratch 02-nginx-container 03-nginx-container-7segment; do
    echo ">>> Building in $d"
    podman build -t "semik-counter-$d" "$d/"
done