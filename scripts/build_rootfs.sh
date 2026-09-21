#!/bin/bash
set -e

SUITE=bookworm
ARCH=amd64
ROOT=rootfs

rm -rf $ROOT
mkdir -p $ROOT

sudo debootstrap --arch=$ARCH --variant=minbase $SUITE $ROOT http://deb.debian.org/debian

sudo chroot $ROOT bash -c "
  apt-get update
  apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    wget curl ca-certificates \
    libgl1-mesa-dri libgl1-mesa-glx \
    x11vnc xvfb xserver-xorg-video-fbdev
  apt-get clean
"

# FIX: safe tar command for GitHub Actions
sudo tar --numeric-owner --xattrs --acls -czf rootfs.tar.gz -C $ROOT .

echo "rootfs.tar.gz built successfully"
