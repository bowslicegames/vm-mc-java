#!/bin/bash
set -e
OUT=/out
ROOTFS_TAR=${OUT}/rootfs.tar.gz
DEBIAN_SUITE=bookworm
ARCH=amd64

# Create minimal Debian rootfs with OpenJDK 17 (headless) and Xvfb + minimal X libs
TMPDIR=/tmp/rootfs
rm -rf $TMPDIR
mkdir -p $TMPDIR

debootstrap --arch=${ARCH} --variant=minbase ${DEBIAN_SUITE} $TMPDIR http://deb.debian.org/debian

chroot $TMPDIR /bin/bash -c "apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless x11vnc xvfb xserver-xorg-video-fbdev \
    libgl1-mesa-dri libgl1-mesa-glx pulseaudio wget ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*"

# Create a user for convenience
chroot $TMPDIR /bin/bash -c "useradd -m -s /bin/bash dev && echo 'dev:dev' | chpasswd && adduser dev sudo"

# Add a tiny launcher script
cat > $TMPDIR/usr/local/bin/startup.sh <<'EOF'
#!/bin/bash
# Start X virtual framebuffer and VNC for remote display
Xvfb :0 -screen 0 1024x768x24 &>/dev/null &
export DISPLAY=:0
# Start a lightweight window manager if present (optional)
# Start a VNC server for remote viewing
x11vnc -display :0 -nopw -forever -shared &>/dev/null &
EOF
chmod +x $TMPDIR/usr/local/bin/startup.sh

# Pack rootfs
tar -C $TMPDIR -czf $ROOTFS_TAR .
echo "Created $ROOTFS_TAR"
