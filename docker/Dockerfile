# Build environment for ./compile.sh (used by docker-compose.yml in the repo root).
# Package list is kept in sync with prepare_host() in lib/functions/host/prepare-host.sh,
# so the script finds everything preinstalled and does not hit apt on every run.
# python3-pkg-resources/python3-setuptools are not in that list (preinstalled on
# GitHub runners) but u-boot's binman needs them.
FROM ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get -y dist-upgrade \
    && apt-get install -y --no-install-recommends \
       acl aptly aria2 bc binfmt-support bison btrfs-progs build-essential \
       busybox ca-certificates ccache cpio cryptsetup curl debian-archive-keyring \
       debian-keyring debootstrap device-tree-compiler dialog dirmngr dnsmasq-base dosfstools \
       dwarves f2fs-tools fakeroot fdisk flex gawk gcc-aarch64-linux-gnu \
       gcc-arm-linux-gnueabi gdisk git gnupg gpg imagemagick jq kmod \
       libbison-dev libc6-dev-armhf-cross libcrypto++-dev libelf-dev libfdt-dev \
       libfile-fcntllock-perl libfl-dev liblz4-tool libmpc-dev libncurses-dev \
       libpython2.7-dev libssl-dev libusb-1.0-0-dev linux-base locales lzop \
       ncurses-base ncurses-term nfs-kernel-server ntpdate p7zip-full parallel \
       parted patchutils pigz pixz pkg-config psmisc pv python2 python3 \
       python3-dev python3-distutils python3-pkg-resources python3-setuptools qemu-user-static rsync sudo swig systemd \
       systemd-container tzdata u-boot-tools udev unzip uuid uuid-dev \
       uuid-runtime wget whiptail xxd xz-utils zip zlib1g-dev zstd \
    && if [ "$(dpkg --print-architecture)" = amd64 ]; then \
         apt-get install -y --no-install-recommends \
           distcc lib32ncurses-dev lib32stdc++6 libc6-i386; \
       elif [ "$(dpkg --print-architecture)" = arm64 ]; then \
         apt-get install -y --no-install-recommends \
           gcc-arm-none-eabi libc6-amd64-cross qemu; \
       fi \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8' TERM=screen

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /root/armbian
ENTRYPOINT [ "/bin/bash", "/usr/local/bin/entrypoint.sh" ]
