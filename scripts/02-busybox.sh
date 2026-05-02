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

BB_CFLAGS="-Os -pipe -fcf-protection=none -fno-stack-protector"
BB_CXXFLAGS="$BB_CFLAGS -fno-exceptions -fno-rtti"

# Build suid version
cp ../busybox-1.36.1_config_suid .config
sed -i 's/^CONFIG_EXTRA_CFLAGS=.*/CONFIG_EXTRA_CFLAGS=""/' .config
make oldconfig
make CFLAGS="$BB_CFLAGS" CXXFLAGS="$BB_CXXFLAGS" \
     KBUILD_CFLAGS="$BB_CFLAGS" -j$(nproc)

mkdir -p /tmp/pkg
make CFLAGS="$BB_CFLAGS" KBUILD_CFLAGS="$BB_CFLAGS" \
     CONFIG_PREFIX=/tmp/pkg install
mv /tmp/pkg/bin/busybox /tmp/pkg/bin/busybox.suid
chmod u+s /tmp/pkg/bin/busybox.suid

# Build nosuid version
cp ../busybox-1.36.1_config_nosuid .config
sed -i 's/^CONFIG_EXTRA_CFLAGS=.*/CONFIG_EXTRA_CFLAGS=""/' .config
make oldconfig
make CFLAGS="$BB_CFLAGS" CXXFLAGS="$BB_CXXFLAGS" \
     KBUILD_CFLAGS="$BB_CFLAGS" -j$(nproc)
make CFLAGS="$BB_CFLAGS" KBUILD_CFLAGS="$BB_CFLAGS" \
     CONFIG_PREFIX=/tmp/pkg install

cp -r /tmp/pkg/* $TC/
cd "$REPO_DIR/src/busybox"

echo "BusyBox done."
