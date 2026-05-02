#!/bin/bash
set -e
echo "--- [1/5] Building cross-toolchain ---"

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export TC="${TC:-$REPO_DIR/output}"
export TC_TGT=i686-tc-linux-gnu
export LC_ALL=POSIX
export PATH=$TC/tools/bin:/usr/local/bin:/bin:/usr/bin

cd "$REPO_DIR/src/toolchain"

# Binutils (pass 1)
echo "Building binutils..."
tar -xf binutils-2.41.tar.xz
cd binutils-2.41
mkdir -p build && cd build
../configure --prefix=$TC/tools --with-sysroot=$TC --target=$TC_TGT \
    --disable-nls --enable-gprofng=no --disable-werror
make -j$(nproc)
make install
cd "$REPO_DIR/src/toolchain"
rm -rf binutils-2.41

# GCC (pass 1 - cross compiler)
echo "Building GCC pass 1..."
tar -xf gcc-13.2.0.tar.xz
cd gcc-13.2.0
mkdir -p build && cd build
../configure \
    --target=$TC_TGT \
    --prefix=$TC/tools \
    --with-glibc-version=2.38 \
    --with-sysroot=$TC \
    --with-newlib \
    --without-headers \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-shared \
    --disable-multilib \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-libstdcxx \
    --enable-languages=c,c++
make -j$(nproc)
make install
cd "$REPO_DIR/src/toolchain"

# Linux headers
echo "Installing Linux headers..."
tar -xf linux-6.6.5.tar.xz
cd linux-6.6.5
make mrproper
make headers
find usr/include -name '.*h' -delete
cp -rv usr/include $TC/usr/
cd "$REPO_DIR/src/toolchain"
rm -rf linux-6.6.5

# glibc
echo "Building glibc..."
tar -xf glibc-2.38.tar.xz
cd glibc-2.38
mkdir -p build && cd build
echo "rootsbindir=/usr/sbin" > configparms
../configure \
    --prefix=/usr \
    --host=$TC_TGT \
    --build=$(../scripts/config.guess) \
    --enable-kernel=5.15.10 \
    --with-headers=$TC/usr/include \
    --disable-nscd \
    libc_cv_slibdir=/lib
make -j$(nproc)
make DESTDIR=$TC install
sed '/RTLDLIST=/s@/usr@@g' -i $TC/usr/bin/ldd
cd "$REPO_DIR/src/toolchain"

echo "Toolchain done."
