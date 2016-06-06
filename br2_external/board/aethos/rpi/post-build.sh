#!/bin/sh

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
cat <<EOF > ${TARGET_DIR}/lib/systemd/system/aethos-hostname.service
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

cat <<EOF > ${TARGET}/usr/bin/aethos-hostname
#!/bin/bash
!/bin/sh
# Filename:     /etc/dhcp/dhclient-exit-hooks.d/hostname
# Purpose:      Used by dhclient-script to set the hostname of the system
#               to match the DNS information for the host as provided by
#               DHCP.
#


# Do not update hostname for virtual machine IP assignments
if [ "$interface" != "eth0" ] && [ "$interface" != "wlan0" ]
then
    return
fi


if [ "$reason" != BOUND ] && [ "$reason" != RENEW ] \
   && [ "$reason" != REBIND ] && [ "$reason" != REBOOT ]
then
        return
fi

hostname=$(host $new_ip_address | cut -d ' ' -f 5 | sed -r 's/((.*)[^\.])\.?/\1/g' )
echo $hostname > /etc/hostname.aethos
hostnamectl set-hostname $hostname
EOF
chmod u+x ${TARGET}/usr/bin/aethos-hostname
