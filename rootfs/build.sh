#/bin/bash

DIST=bookworm

if [ `id -u` -ne 0 ]
  then echo "Please run as root"
  exit
fi

mkdir debian build
debootstrap --arch=arm64 --foreign $DIST debian https://mirrors.tuna.tsinghua.edu.cn/debian/
LANG=C LANGUAGE=C LC_ALL=C chroot debian /debootstrap/debootstrap --second-stage
cp ../deb-pkgs/*.deb ../kernel/linux-headers-*.deb ../kernel/linux-image-*.deb chroot.sh debian/tmp/
mount --bind /proc debian/proc
mount --bind /dev debian/dev
mount --bind /dev/pts debian/dev/pts
mount --bind /sys debian/sys
LANG=C LANGUAGE=C LC_ALL=C chroot debian /tmp/chroot.sh
rm -rf debian/tmp/* debian/root/.bash_history
umount debian/proc
umount debian/dev/pts
umount debian/dev
umount debian/sys

#dd if=/dev/zero of=debian-ufi003.img bs=1M count=$(( $(df -m --output=used debian | tail -1 | awk '{print $1}') + 100 ))
dd if=/dev/zero of=debian-ufi003.img bs=1M count=$(( $(du -ms debian | cut -f1) + 100 ))
mkfs.ext4 -L rootfs debian-ufi003.img
mount debian-ufi003.img build
rsync -aH debian/ build/
umount build
img2simg debian-ufi003.img rootfs.img
rm -rf debian-ufi003.img debian build
