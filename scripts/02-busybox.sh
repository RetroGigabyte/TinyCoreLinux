#!/bin/bash
set -e
echo "--- [2/5] Building BusyBox ---"

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export TC="${TC:-$REPO_DIR/output}"

cd "$REPO_DIR/src/busybox"

tar -xf busybox-1.36.1.tar.bz2
cd busybox-1.36.1

patch -Np1 -i ../busybox-1.27.1-wget-make-default-timeout-configurable.patch
patch -Np1 -i ../busybox-1.29.3_root_path.patch
patch -Np1 -i ../busybox-1.33.0_modprobe.patch
patch -Np0 -i ../busybox-1.33.0_tc_depmod.patch

BB_CC="gcc -flto -march=i486 -mtune=i686 -Os -pipe -fcf-protection=none"
BB_CXX="g++ -flto -march=i486 -mtune=i686 -Os -pipe -fno-exceptions -fno-rtti -fcf-protection=none"

# Build suid version
cp ../busybox-1.36.1_config_suid .config
make oldconfig
make CC="$BB_CC" CXX="$BB_CXX" -j$(nproc)

mkdir -p /tmp/pkg
make CC="$BB_CC" CONFIG_PREFIX=/tmp/pkg install
mv /tmp/pkg/bin/busybox /tmp/pkg/bin/busybox.suid
chmod u+s /tmp/pkg/bin/busybox.suid

# Build nosuid version
cp ../busybox-1.36.1_config_nosuid .config
make oldconfig
make CC="$BB_CC" CXX="$BB_CXX" -j$(nproc)
make CC="$BB_CC" CONFIG_PREFIX=/tmp/pkg install

cp -r /tmp/pkg/* $TC/
cd "$REPO_DIR/src/busybox"

echo "BusyBox done."
