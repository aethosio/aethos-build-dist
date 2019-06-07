#!/bin/bash
sudo mkdir -p /var/lib/lxc/aethos/rootfs
sudo umount /var/lib/lxc/aethos/rootfs
sudo cp /var/lib/lxc/build/rootfs/root/buildroot-x86_64-full-build/images/rootfs.ext2 /var/lib/lxc/aethos
sudo mount /var/lib/lxc/aethos/rootfs.ext2 /var/lib/lxc/aethos/rootfs