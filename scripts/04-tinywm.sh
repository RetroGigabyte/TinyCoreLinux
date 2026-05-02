#!/bin/bash
set -e
echo "--- [4/5] Building TinyWM ---"

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export TC="${TC:-$REPO_DIR/output}"

cd "$REPO_DIR/tinywm"
tar -xf tinywm.tar.gz
cd tinywm-master

gcc -o tinywm tinywm.c -lX11 -Os -pipe -fcf-protection=none
mkdir -p $TC/usr/local/bin
cp tinywm $TC/usr/local/bin/
chmod +x $TC/usr/local/bin/tinywm

mkdir -p $TC/home/tc
cat > $TC/home/tc/.xinitrc << 'EOF'
#!/bin/sh
exec tinywm
EOF
chmod +x $TC/home/tc/.xinitrc

cat > $TC/home/tc/.profile << 'EOF'
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    startx
fi
EOF

echo "TinyWM done."
