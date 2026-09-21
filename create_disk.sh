#!/bin/bash
set -e
if [ $# -ne 2 ]; then
  echo "Usage: $0 rootfs.tar.gz disk.img"
  exit 1
fi
ROOTFS_TAR=$1
DISK_IMG=$2
IMG_SIZE=2048M

# Create empty image
fallocate -l $IMG_SIZE $DISK_IMG
parted $DISK_IMG --script mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on

LOOP=$(losetup --show -f -P $DISK_IMG)
PART=${LOOP}p1
mkfs.ext4 $PART -F
MNT=$(mktemp -d)
mount $PART $MNT
tar -xzf $ROOTFS_TAR -C $MNT
# Ensure /etc/fstab and grub not required for QEMU user boot
umount $MNT
losetup -d $LOOP
echo "Disk image created: $DISK_IMG"
