# Allwinner H2+/H3 quad core 256/512MB RAM SoC WiFi SPI
BOARD_NAME="WuKong Pi"
BOARD_VENDOR="wukong"
BOARDFAMILY="sun8i"
BOARD_MAINTAINER=""
INTRODUCED="2023"
BOOTCONFIG="wukongpi_defconfig"
MODULES="g_serial"
MODULES_BLACKLIST="lima sunxi_cedrus"
DEFAULT_OVERLAYS="usbhost2 usbhost3"
DEFAULT_CONSOLE="serial"
HAS_VIDEO_OUTPUT="no"
SERIALCON="ttyS0,ttyGS0"
KERNEL_TARGET="current,edge,legacy"
KERNEL_TEST_TARGET="current"
# mDNS: the board is reachable as <hostname>.local
PACKAGE_LIST_BOARD="avahi-daemon"
# Kernel/DTB packages in the Armbian apt repository have no WuKong Pi device tree:
# hold the Armbian packages of the image so apt upgrade can't make it unbootable
BSPFREEZE="yes"

# The ext4 writer of wukong-imager (classic_ext4) refuses 64bit and metadata_csum, which
# armbian/build dropped from its mkfs options after 23.02. mkopts is local to
# prepare_partitions(), the hook runs inside it.
function pre_prepare_partitions__wukongpi_classic_ext4() {
	mkopts[ext4]+=" -O ^64bit,^metadata_csum"
}

# armbian-firstlogin of armbian/build ddfe91a (main, 2026-10-23): an imager preset runs first
# login unattended on the root autologin console; the v26.08 one stops there at every question
# the preset doesn't answer (root password, shell, real name, locale...) until somebody logs in
# over SSH, and then runs twice. Drop this and userpatches/bsp/ with ARMBIAN_REF >= v26.11.
function post_family_tweaks_bsp__wukongpi_firstlogin() {
	run_host_command_logged install -m 0755 "${USERPATCHES_PATH}/bsp/armbian-firstlogin" \
		"${destination}/usr/lib/armbian/armbian-firstlogin"
}
