#!/bin/bash
set -e
echo "--- [3/5] Building kernel ---"

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export TC="${TC:-$REPO_DIR/output}"

cd "$REPO_DIR/src/kernel"

tar -xf linux-6.6.8-patched.txz
cd linux-6.6.8

cp ../config-6.6.8-tinycore .config

make oldconfig
make CC=gcc KCFLAGS="-Os -pipe -fcf-protection=none" \
     -j$(nproc) bzImage modules

mkdir -p $TC/boot
cp arch/x86/boot/bzImage $TC/boot/vmlinuz

cd "$REPO_DIR/src/kernel"
echo "Kernel done."
