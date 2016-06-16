#!/bin/sh

# This script is a bit hackish and probably a lot of it can be moved
# into Buildroot, but since I'm not familiar with Buildroot then
# for now I'm going to hack the things I can't figure out where it should
# otherwise go.

set -u
set -e

if [ -f ${TARGET_DIR}/etc/inittab ]; then
  # Add a console on tty1
  grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
  sed -i '/GENERIC_SERIAL/a\
  tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# Assuming systemd

# Replace symbolic link of /etc/resolv.conf
rm -rf ${TARGET_DIR}/etc/resolv.conf
ln -s ../run/systemd/resolve/resolv.conf ${TARGET_DIR}/etc/resolv.conf

cat <<EOF > ${TARGET_DIR}/etc/systemd/resolved.conf
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
# Entries in this file show the compile time defaults.
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See resolved.conf(5) for details

[Resolve]
# I use 192.168.1.200 as my overlay DNS.
# TODO Don't hard-code this; when we get etcd running, use that config.
DNS=192.168.1.200
#FallbackDNS=8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844
Domains=local
#LLMNR=yes
#DNSSEC=no
EOF

# Support for dynamic host name
cat <<'EOF' > ${TARGET_DIR}/lib/systemd/system/aethos-hostname.service
[Unit]
Description=AethOS Node host name
After=systemd-resolved.service
After=syslog.target

[Service]
ExecStart=/bin/bash /usr/bin/aethos-hostname
ExecStop=/bin/true
StandardOutput=syslog+console

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' > ${TARGET_DIR}/usr/bin/aethos-hostname
#!/bin/bash
new_ip_address=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
hostname=$(host $new_ip_address | cut -d ' ' -f 5 | sed -r 's/((.*)[^\.])\.?/\1/g' )
echo $hostname > /etc/hostname.aethos
hostnamectl set-hostname $hostname
EOF
chmod u+x ${TARGET_DIR}/usr/bin/aethos-hostname

###############################
# Additional Go HOST tools

SAVE_PATH=$PATH
# HOST_GO_ENV=`cat /root/HOST_GO_ENV`;export $HOST_GO_ENV;PATH=$PATH:$GOBIN:$HOST_DIR/usr/bin;GOBIN_SAVE=$GOBIN;export GOBIN=
# go get github.com/Masterminds/glide
# cd $GOPATH/src/github.com/Masterminds/glide
# GOARCH=
# make build
# cp glide $HOST_DIR/usr/bin/glide

###############################
# Additional Go TARGET builds

PATH=$SAVE_PATH
TARGET_GO_ENV=`cat /root/TARGET_GO_ENV`;export $TARGET_GO_ENV;PATH=$PATH:$GOBIN;GOBIN_SAVE=$GOBIN;export GOBIN=

#go get github.com/aethos/etcd_v0

# cd /root/coreos/src/third_party/etcd
#./build
#
# if [ -z "${GOARCH}" ] || [ "${GOARCH}" = "$(go env GOHOSTARCH)" ]; then
#         out="bin"
# else
#         out="bin/${GOARCH}"
# fi
#
#
# ${INSTALL} -D -m 0755 ${out}/etcd ${TARGET_DIR}/usr/bin/etcd
# ${INSTALL} -D -m 0755 ${out}/etcdctl ${TARGET_DIR}/usr/bin/etcdctl
