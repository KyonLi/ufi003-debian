# ufi003-debian
适用于UFI003_MB_V02的Debian构建脚本

## 本地构建
1. 克隆本仓库
2. 安装软件包 `debootstrap rsync qemu-user-static binfmt-support android-sdk-libsparse-utils`
3. 进入rootfs目录，以root权限运行`build.sh`
4. 构建完成后会在rootfs目录得到rootfs.img
