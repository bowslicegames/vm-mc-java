#!/bin/bash
set -e
IMG=${1:-disk.img}
KERNEL=kernel/vmlinuz
if [ ! -f "$IMG" ]; then
  echo "Disk image $IMG not found"
  exit 1
fi
if [ ! -f "$KERNEL" ]; then
  echo "Kernel not found in kernel/; please place a vmlinuz there or use a distro kernel"
  exit 1
fi

qemu-system-x86_64 \
  -m 4096 \
  -smp 2 \
  -kernel $KERNEL \
  -append "root=/dev/sda1 rw console=ttyS0 init=/usr/local/bin/startup.sh" \
  -drive file=$IMG,format=raw,if=virtio \
  -nographic \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=net0
