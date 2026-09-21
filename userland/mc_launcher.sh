#!/bin/bash
set -e
# Run inside the VM as root or sudo
apt-get update
apt-get install -y openjdk-17-jre-headless wget unzip
# Create a dev user and workspace
su - dev -c "mkdir -p ~/mc && cd ~/mc && echo 'Ready for LWJGL and Minecraft assets' > README"
echo "Java installed. Next: download LWJGL and Minecraft launcher manually or via script."
