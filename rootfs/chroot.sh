#!/bin/bash

LANG_TARGET=en_US.UTF-8
PASSWORD=1234
NAME=ufi003
PARTUUID=a7ab80e8-e9d1-e8cd-f157-93f69b1d141e

cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
# deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src http://deb.debian.org/debian/ bookworm-backports main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

cat <<EOF > /etc/fstab
PARTUUID=$PARTUUID / ext4 defaults,noatime,commit=600,errors=remount-ro 0 1
tmpfs /tmp tmpfs defaults,nosuid 0 0
EOF

apt-get update
apt-get full-upgrade -y
apt-get install -y locales network-manager openssh-server systemd-timesyncd fake-hwclock zram-tools rmtfs qrtr-tools
apt-get install -y /tmp/*.deb
sed -i -e "s/# $LANG_TARGET UTF-8/$LANG_TARGET UTF-8/" /etc/locale.gen
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG=$LANG_TARGET LC_ALL=$LANG_TARGET LANGUAGE=$LANG_TARGET
echo -n >/etc/resolv.conf
echo -e "$PASSWORD\n$PASSWORD" | passwd
echo $NAME > /etc/hostname
sed -i "1a 127.0.0.1\t$NAME" /etc/hosts
sed -i "s/::1\t\tlocalhost/::1\t\tlocalhost $NAME/g" /etc/hosts
sed -i 's/^.\?PermitRootLogin.*$/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^.\?ALGO=.*$/ALGO=lzo-rle/g' /etc/default/zramswap
sed -i 's/^.\?PERCENT=.*$/PERCENT=300/g' /etc/default/zramswap

vmlinuz_name=$(basename /boot/vmlinuz-*)
cat <<EOF > /tmp/info.md
- 内核版本: ${vmlinuz_name#*-}
- 默认用户名: root
- 默认密码: $PASSWORD
- WiFi名称: openstick-failsafe
- WiFi密码: 12345678
EOF
rm -rf /etc/ssh/ssh_host_* /var/lib/apt/lists
apt clean
exit
