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
