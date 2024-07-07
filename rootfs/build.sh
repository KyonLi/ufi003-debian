#/bin/bash

DIST=bookworm
K_IMAGE_URL="https://github.com/KyonLi/ufi003-kernel/releases/download/5.18.0-3/Image.gz"
K_IMAGE_DEB_URL="https://github.com/KyonLi/ufi003-kernel/releases/download/5.18.0-3/linux-image-5.18.0-handsomehack-g533401025051_5.18.0-handsomehack-g533401025051-1_arm64.deb"
K_HEADERS_DEB_URL="https://github.com/KyonLi/ufi003-kernel/releases/download/5.18.0-3/linux-headers-5.18.0-handsomehack-g533401025051_5.18.0-handsomehack-g533401025051-1_arm64.deb"

if [ `id -u` -ne 0 ]
  then echo "Please run as root"
  exit
fi

wget -P ../kernel "$K_IMAGE_URL"
wget -P ../kernel "$K_IMAGE_DEB_URL"
wget -P ../kernel "$K_HEADERS_DEB_URL"

mkdir debian build
debootstrap --arch=arm64 --foreign $DIST debian https://deb.debian.org/debian/
# cp /usr/bin/qemu-aarch64-static debian/usr/bin/
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
mkfs.ext4 -L rootfs debian-ufi003.img
UUID=$(blkid -s UUID -o value debian-ufi003.img)
cat <<EOF > debian/etc/fstab
UUID=$UUID / ext4 defaults,noatime,commit=600,errors=remount-ro 0 1
tmpfs /tmp tmpfs defaults,nosuid 0 0
EOF
mount debian-ufi003.img build
rsync -aH debian/ build/
umount build
img2simg debian-ufi003.img rootfs.img
xz rootfs.img
rm -rf debian-ufi003.img debian build > /dev/null 2>&1

cd ../kernel
./build-boot-img.sh
rm -rf initrd.img *.dtb *.deb Image.gz > /dev/null 2>&1
