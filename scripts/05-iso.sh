#!/bin/bash
set -e
echo "--- [5/5] Building ISO ---"

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export TC="${TC:-$REPO_DIR/output}"

ISO_DIR="$REPO_DIR/iso"
mkdir -p $ISO_DIR/boot/isolinux

cp $TC/boot/vmlinuz $ISO_DIR/boot/vmlinuz

echo "Packing rootfs..."
cd $TC
find . | cpio -o -H newc | gzip -9 > $ISO_DIR/boot/core.gz

cp /usr/lib/ISOLINUX/isolinux.bin $ISO_DIR/boot/isolinux/
cp /usr/lib/syslinux/modules/bios/ldlinux.c32 $ISO_DIR/boot/isolinux/

cat > $ISO_DIR/boot/isolinux/isolinux.cfg << 'EOF'
DEFAULT core
LABEL core
    KERNEL /boot/vmlinuz
    INITRD /boot/core.gz
    APPEND quiet
EOF

genisoimage -l -J -R -V "CustomTCL-TinyWM" \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -b boot/isolinux/isolinux.bin \
    -c boot/isolinux/boot.cat \
    -o "$TC/custom-tcl-tinywm.iso" \
    $ISO_DIR

echo "ISO created: $TC/custom-tcl-tinywm.iso"
