#!/bin/bash
set -e

ROOTFS=$1
DISK=$2
SIZE=2048M

fallocate -l $SIZE $DISK
parted $DISK --script mklabel msdos mkpart primary ext4 1MiB 100%

LOOP=$(sudo losetup --show -f -P $DISK)
PART=${LOOP}p1

sudo mkfs.ext4 $PART -F
MNT=$(mktemp -d)
sudo mount $PART $MNT

sudo tar -xzf $ROOTFS -C $MNT

sudo umount $MNT
sudo losetup -d $LOOP

echo "disk.img created"
