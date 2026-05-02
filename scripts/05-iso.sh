#!/bin/bash
set -e
echo "--- [5/5] Building ISO ---"

ISO_DIR=/build/iso
mkdir -p $ISO_DIR/boot/isolinux

# Copy kernel
cp $TC/boot/vmlinuz $ISO_DIR/boot/vmlinuz

# Pack rootfs into initramfs
echo "Packing rootfs..."
cd $TC
find . | cpio -o -H newc | gzip -9 > $ISO_DIR/boot/core.gz

# Bootloader config
cp /usr/lib/ISOLINUX/isolinux.bin $ISO_DIR/boot/isolinux/
cp /usr/lib/syslinux/modules/bios/ldlinux.c32 $ISO_DIR/boot/isolinux/

cat > $ISO_DIR/boot/isolinux/isolinux.cfg << 'EOF'
DEFAULT core
LABEL core
    KERNEL /boot/vmlinuz
    INITRD /boot/core.gz
    APPEND quiet
EOF

# Build ISO
genisoimage -l -J -R -V "CustomTCL-TinyWM" \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -b boot/isolinux/isolinux.bin \
    -c boot/isolinux/boot.cat \
    -o /build/output/custom-tcl-tinywm.iso \
    $ISO_DIR

echo "ISO created: /build/output/custom-tcl-tinywm.iso"
