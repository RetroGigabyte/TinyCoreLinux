#!/bin/bash
set -e
echo "--- [5/5] Building ISO ---"

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export TC="${TC:-$REPO_DIR/output}"

ISO_DIR="$REPO_DIR/iso"
ROOTFS="$REPO_DIR/rootfs"

mkdir -p $ISO_DIR/boot/isolinux
mkdir -p $ROOTFS

echo "Building rootfs..."
# Copy BusyBox binaries
cp -a $TC/bin $TC/sbin $TC/usr $TC/lib* $ROOTFS/ 2>/dev/null || true

# Create essential directories
mkdir -p $ROOTFS/{dev,proc,sys,etc,tmp,home/tc,var/log,usr/local/bin}

# Copy TinyWM
cp $TC/usr/local/bin/tinywm $ROOTFS/usr/local/bin/

# Basic /etc files
cat > $ROOTFS/etc/passwd << 'EOF'
root:x:0:0:root:/root:/bin/sh
tc:x:1001:50:tc:/home/tc:/bin/sh
EOF

cat > $ROOTFS/etc/group << 'EOF'
root:x:0:
staff:x:50:
EOF

# X startup for tc user
cp $TC/home/tc/.xinitrc $ROOTFS/home/tc/.xinitrc 2>/dev/null || true
cp $TC/home/tc/.profile $ROOTFS/home/tc/.profile 2>/dev/null || true

# Simple init script
cat > $ROOTFS/init << 'EOF'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev 2>/dev/null || mdev -s
echo "Welcome to Tiny Core Linux + TinyWM"
exec /bin/sh
EOF
chmod +x $ROOTFS/init

echo "Packing rootfs..."
cd $ROOTFS
find . | cpio -o -H newc | gzip -9 > $ISO_DIR/boot/core.gz

echo "Rootfs size: $(du -sh $ISO_DIR/boot/core.gz | cut -f1)"

cp $TC/boot/vmlinuz $ISO_DIR/boot/vmlinuz

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
    -o "$REPO_DIR/output/custom-tcl-tinywm.iso" \
    $ISO_DIR

echo "ISO created: $REPO_DIR/output/custom-tcl-tinywm.iso"
