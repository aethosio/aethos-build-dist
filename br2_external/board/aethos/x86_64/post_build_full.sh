#!/bin/bash
echo Working directory: `pwd`
echo Args: $1
echo Host: $HOST_DIR
echo Staging: $STAGING_DIR
echo Target: $TARGET_DIR
env > /root/build_env.txt
# Working directory: /root/buildroot
# Args: /root/buildroot-x86_64-full-build/target
# Host: /root/buildroot-x86_64-full-build/host
# Staging: /root/buildroot-x86_64-full-build/host/usr/x86_64-buildroot-linux-gnu/sysroot
# Target: /root/buildroot-x86_64-full-build/target

# Change any /bin/sh shells to use /bin/bash instead.
#
sed -i 's%/bin/sh%/bin/bash%' $TARGET_DIR/etc/passwd

# Copy install2 (post CHROOT installation script)
mkdir -p $TARGET_DIR/install
cp /root/abd/install2.sh $TARGET_DIR/install/install.sh
