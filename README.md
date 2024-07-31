# ufi003-debian
适用于UFI003_MB_V02的Debian构建脚本

## 特性
- NFS client v2/v3/v4, NFS server v3/v4
- KSMBD
- 默认300% zram
- boot-no-modem-oc.img内核超频至1.2GHz

## 手动更换内核
```shell
cd /tmp
wget KERN_DEB_URL
wget BOOT_IMG_URL
apt purge linux-image*
apt install ./linux-image*.deb
dd if=/tmp/boot.img of=/dev/disk/by-partlabel/boot bs=1M
reboot
```

## 本地构建
1. 克隆本仓库
2. 安装软件包 `debootstrap rsync qemu-user-static binfmt-support android-sdk-libsparse-utils`
3. 进入rootfs目录，以root权限运行`build.sh`
4. 构建完成后会在rootfs目录得到rootfs.img，kernel目录得到boot.img
