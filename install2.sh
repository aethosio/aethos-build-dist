#!/bin/bash
#!/bin/bash
# This is the install script after chroot
cd /install
wget ftp://alpha.gnu.org/gnu/grub/grub-0.97.tar.gz
tar -xvf grub-0.97.tar.gz
cd grub-0.97
./configure
make install
