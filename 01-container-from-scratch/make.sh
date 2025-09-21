#!/bin/bash

if [ -d debian-rootfs ]; then
    echo "debian-rootfs directory already exists. Please remove it first."
    echo "sudo rm -rf debian-rootfs"
    exit 1
fi
sudo apt-get install debootstrap
sudo debootstrap --arch=amd64 stable ./debian-rootfs http://deb.debian.org/debian/
sudo tar -C ./debian-rootfs -czf debian-rootfs.tar.gz .
ls -lh debian-rootfs.tar.gz
podman build -t semik-debian .
podman images | head -2