#!/bin/bash
set -e
echo "--- [3/5] Building kernel ---"

cd /build/src/kernel

tar -xf linux-6.6.8-patched.txz
cd linux-6.6.8

cp ../config-6.6.8-tinycore .config

make oldconfig
make CC="gcc -march=i486 -mtune=i686 -Os -pipe" \
     -j$(nproc) bzImage modules

mkdir -p $TC/boot
cp arch/x86/boot/bzImage $TC/boot/vmlinuz

cd /build/src/kernel
echo "Kernel done."
