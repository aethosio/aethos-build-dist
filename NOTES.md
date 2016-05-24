# AethOS Build Dist Notes


## LXC

LXC containers are located in `/var/lib/lxc/<container>`.  In this folder is `config` which is a text file that contains the container configuration and `rootfs/` which is a folder that contains the root file system for the container.

If you use `lxc-create -B btrfs` then where is the file system? 

Templates for LXC are located in /usr/share/lxc/templates
