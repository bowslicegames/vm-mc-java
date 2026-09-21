# vm-mc-java

Starter repo to build a minimal Debian-based VM image with OpenJDK and a small userland for iterating on a fake-GPU → WebGPU pipeline and eventually run Minecraft Java.

Quick steps:
1. Install Docker and qemu-user-static (for debootstrap in Docker).
2. Run `make rootfs` to build the rootfs tarball.
3. Run `make disk` to create a disk image.
4. Run `./qemu/run_qemu.sh` to boot locally with QEMU.
5. Use `userland/mc-launcher.sh` inside the VM to install OpenJDK and LWJGL (or use the Docker build step to preinstall).

See the scripts for details.
