#!/bin/bash
set -e

echo "=== Tiny Core Linux + TinyWM Build ==="

mkdir -p $TC/{usr,lib,var,etc,bin,sbin,tools,sources,dev,proc,sys,run}

bash /build/scripts/01-toolchain.sh
bash /build/scripts/02-busybox.sh
bash /build/scripts/03-kernel.sh
bash /build/scripts/04-tinywm.sh
bash /build/scripts/05-iso.sh

echo "=== Build complete: /build/output/custom-tcl-tinywm.iso ==="
