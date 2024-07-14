#/bin/bash

DIST=bookworm
K_IMAGE_URL="https://github.com/KyonLi/ufi003-kernel/releases/download/6.6.38-1/Image.gz"
K_IMAGE_DEB_URL="https://github.com/KyonLi/ufi003-kernel/releases/download/6.6.38-1/linux-image-6.6.38-msm8916-g7575c9d9bd67_6.6.38-g7575c9d9bd67-1_arm64.deb"
K_HEADERS_DEB_URL="https://github.com/KyonLi/ufi003-kernel/releases/download/6.6.38-1/linux-headers-6.6.38-msm8916-g7575c9d9bd67_6.6.38-g7575c9d9bd67-1_arm64.deb"
UUID=62ae670d-01b7-4c7d-8e72-60bcd00410b7

if [ `id -u` -ne 0 ]
  then echo "Please run as root"
  exit
fi

wget -P ../kernel "$K_IMAGE_URL"
wget -P ../kernel "$K_IMAGE_DEB_URL"
wget -P ../kernel "$K_HEADERS_DEB_URL"

mkdir debian build
debootstrap --arch=arm64 --foreign $DIST debian https://deb.debian.org/debian/
LANG=C LANGUAGE=C LC_ALL=C chroot debian /debootstrap/debootstrap --second-stage
cp ../deb-pkgs/*.deb ../kernel/*.deb chroot.sh debian/tmp/
mount --bind /proc debian/proc
mount --bind /dev debian/dev
mount --bind /dev/pts debian/dev/pts
mount --bind /sys debian/sys
LANG=C LANGUAGE=C LC_ALL=C chroot debian /tmp/chroot.sh
mv debian/tmp/info.md ./
rm -rf debian/tmp/* debian/root/.bash_history > /dev/null 2>&1
cp debian/etc/debian_version ./
cp debian/boot/initrd.img* ../kernel/initrd.img
cp debian/usr/lib/linux-image*/qcom/*ufi003*.dtb ../kernel/
umount debian/proc
umount debian/dev/pts
umount debian/dev
umount debian/sys

echo -e "\n\nNow you can make additional modifications to rootfs.\nPress ENTER to continue"
head -n 1 >/dev/null

#dd if=/dev/zero of=debian-ufi003.img bs=1M count=$(( $(df -m --output=used debian | tail -1 | awk '{print $1}') + 100 ))
dd if=/dev/zero of=debian-ufi003.img bs=1M count=$(( $(du -ms debian | cut -f1) + 100 ))
mkfs.ext4 -L rootfs -U $UUID debian-ufi003.img
mount debian-ufi003.img build
rsync -aH debian/ build/
umount build
img2simg debian-ufi003.img rootfs.img
rm -rf debian-ufi003.img debian build > /dev/null 2>&1

cd ../kernel
./build-boot-img.sh
rm -rf initrd.img *.dtb *.deb Image.gz > /dev/null 2>&1
