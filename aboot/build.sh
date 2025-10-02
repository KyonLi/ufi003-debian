#!/bin/bash

BRANCH=21.0

git clone -b $BRANCH https://github.com/msm8916-mainline/lk2nd.git --depth=1
cd lk2nd
patch -p1 < ../ufi003.patch
make TOOLCHAIN_PREFIX=arm-none-eabi- LK2ND_BUNDLE_DTB="msm8916-512mb-mtp.dtb" LK2ND_COMPATIBLE="thwc,ufi003" lk1st-msm8916 -j$(nproc --all)
echo "lk1st-msm8916-$(lk2nd/scripts/describe-version.sh)" > ../ver.txt
cd ..
mv lk2nd/build-lk1st-msm8916/emmc_appsboot.mbn ./

git clone https://github.com/msm8916-mainline/qtestsign.git --depth=1
qtestsign/qtestsign.py aboot emmc_appsboot.mbn

rm -rf lk2nd qtestsign emmc_appsboot.mbn
