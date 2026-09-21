.PHONY: rootfs disk qemu tinyemu clean

ROOTFS_TAR=rootfs.tar.gz
DISK_IMG=disk.img
ROOTFS_DIR=rootfs

rootfs: $(ROOTFS_TAR)

$(ROOTFS_TAR): Dockerfile.rootfs build_rootfs.sh
    docker build -t vm-rootfs-builder -f Dockerfile.rootfs .
    docker run --rm -v $(PWD):/out vm-rootfs-builder /out/build_rootfs.sh

disk: $(DISK_IMG)

$(DISK_IMG): $(ROOTFS_TAR)
    ./create_disk.sh $(ROOTFS_TAR) $(DISK_IMG)

qemu: $(DISK_IMG)
    ./qemu/run_qemu.sh $(DISK_IMG)

tinyemu:
    ./tinyemu/build_tinyemu.sh

clean:
    rm -f $(ROOTFS_TAR) $(DISK_IMG)
