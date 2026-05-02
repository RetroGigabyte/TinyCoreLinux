FROM --platform=linux/amd64 debian:12-slim

RUN apt-get update && apt-get install -y \
    build-essential gcc g++ make patch cpio \
    libncurses-dev libssl-dev libelf-dev \
    libx11-dev bc bison flex wget curl xz-utils \
    genisoimage syslinux syslinux-common isolinux \
    perl python3 texinfo gettext \
    gawk diffutils file findutils \
    autoconf automake libtool \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY src/ /build/src/
COPY tinywm/ /build/tinywm/
COPY scripts/ /build/scripts/

RUN chmod +x /build/scripts/*.sh

ENV TC=/build/output
ENV TC_TGT=i686-tc-linux-gnu
ENV LC_ALL=POSIX
ENV PATH=/build/output/tools/bin:/usr/local/bin:/bin:/usr/bin

CMD ["/build/scripts/build-all.sh"]
