#!/bin/bash

kubectl delete deployment.apps/cgi-counter deployment.apps/nginx-static \
    service/cgi-counter service/nginx-static pvc/counter-pvc \
    configmap/nginx-static ingress/linuxdays2025 \
    ingress/linuxdays2025-alive --ignore-not-found

for i in *.yaml
do
    kubectl apply -f "$i"
done
