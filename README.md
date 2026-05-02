# Tiny Core Linux + TinyWM

Custom Tiny Core Linux 15.x build with TinyWM window manager.

## Build on Linux (recommended)

### Install dependencies (Ubuntu/Debian)
```bash
sudo apt install build-essential gcc g++ make patch cpio \
    libncurses-dev libssl-dev libelf-dev libx11-dev \
    bc bison flex wget curl xz-utils genisoimage \
    syslinux syslinux-common isolinux \
    perl python3 texinfo gettext gawk autoconf automake libtool
```

### Clone and build
```bash
git clone https://github.com/RetroGigabyte/TinyCoreLinux.git
cd TinyCoreLinux

mkdir -p output
export TC=$(pwd)/output
bash scripts/build-all.sh
```

The finished ISO will be at `output/custom-tcl-tinywm.iso`.

## Build on Mac (Docker)
```bash
docker build -t tcl-builder .
mkdir -p output
docker run --rm -v $(pwd)/output:/build/output tcl-builder
```

> Note: Docker build on Mac uses x86 emulation and will be significantly slower.

## Boot the ISO

Test in QEMU:
```bash
qemu-system-i386 -cdrom output/custom-tcl-tinywm.iso -m 128M
```

Or write to USB:
```bash
sudo dd if=output/custom-tcl-tinywm.iso of=/dev/sdX bs=4M status=progress
```

## What's included
- Linux kernel 6.6.8 (TCL patched)
- BusyBox 1.36.1
- glibc 2.38
- TinyWM window manager (auto-starts on tty1)
