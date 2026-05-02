#!/bin/bash
set -e
echo "--- [4/5] Building TinyWM ---"

cd /build/tinywm
tar -xf tinywm.tar.gz
cd tinywm-master

gcc -o tinywm tinywm.c -lX11 -march=i486 -mtune=i686 -Os -pipe
cp tinywm $TC/usr/local/bin/
chmod +x $TC/usr/local/bin/tinywm

# Basic X startup: launch tinywm as window manager
mkdir -p $TC/home/tc
cat > $TC/home/tc/.xinitrc << 'EOF'
#!/bin/sh
exec tinywm
EOF
chmod +x $TC/home/tc/.xinitrc

# Auto-start X on login for tc user
cat > $TC/home/tc/.profile << 'EOF'
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    startx
fi
EOF

echo "TinyWM done."
