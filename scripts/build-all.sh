#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export SCRIPTS="$REPO_DIR/scripts"
export TC="${TC:-$REPO_DIR/output}"
export TC_TGT=i686-tc-linux-gnu
export LC_ALL=POSIX
export PATH=$TC/tools/bin:/usr/local/bin:/bin:/usr/bin

echo "=== Tiny Core Linux + TinyWM Build ==="
echo "Repo: $REPO_DIR"
echo "Output: $TC"

mkdir -p $TC/{usr,lib,var,etc,bin,sbin,tools,sources,dev,proc,sys,run}

bash "$SCRIPTS/01-toolchain.sh"
bash "$SCRIPTS/02-busybox.sh"
bash "$SCRIPTS/03-kernel.sh"
bash "$SCRIPTS/04-tinywm.sh"
bash "$SCRIPTS/05-iso.sh"

echo "=== Build complete: $TC/custom-tcl-tinywm.iso ==="
