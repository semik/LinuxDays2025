#!/bin/bash

kubectl apply -f nginx-configmap.yaml
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml

kubectl apply -f counter-pvc.yaml
kubectl apply -f counter-deployment.yaml
kubectl apply -f counter-service.yaml

kubectl apply -f linuxdays2025-ingress.yaml