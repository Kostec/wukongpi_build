# wukongpi_build

Armbian images for the WuKong Pi (Allwinner H2+/H3, 256/512 MB RAM, XR819 Wi-Fi).

This repository only holds the board support. The build framework is
[armbian/build](https://github.com/armbian/build) at the ref from [`ARMBIAN_REF`](ARMBIAN_REF);
it is checked out at build time and the files from `userpatches/` are put next to it.

```
ARMBIAN_REF                                        armbian/build release branch, tag or commit
userpatches/config/boards/wukongpi.csc             board config
userpatches/kernel/sunxi-dt_32/*.dts               kernel device tree, used for every kernel branch
userpatches/u-boot/v2026.07-sunxi/board_wukongpi/  U-Boot defconfig and device tree
docker/, docker-compose.yml                        build container (also used by CI)
```

### Kernel branch

Select the kernel with `BRANCH=` (versions for armbian/build v26.08):

| BRANCH    | Kernel   |
|-----------|----------|
| `legacy`  | 6.12 LTS |
| `current` | 6.18 LTS |
| `edge`    | 7.1      |

### Release

Select the userspace with `RELEASE=`: `trixie` (Debian 13), `noble` (Ubuntu 24.04) or
`resolute` (Ubuntu 26.04). `bookworm`, `jammy`, `forky` and `sid` are community supported
by Armbian and may break.

### Building (Docker)

Requirements: Docker (on Windows: Docker Desktop with the WSL 2 backend, switched to
**Linux containers**), ~40 GB of disk space.

```
docker compose build
docker compose run --rm build BOARD=wukongpi BRANCH=current RELEASE=trixie BUILD_MINIMAL=no BUILD_DESKTOP=no KERNEL_CONFIGURE=no
```

- `docker compose run --rm build shell` gives a shell in the build environment.
- Results are written to `output/` (the image is in `output/images/`).
- armbian/build, downloaded sources and the rootfs cache are kept in the Docker volumes
  `armbian-build`, `armbian-build-cache` and `armbian-build-tmp` (`docker compose down -v` deletes them).
- Another armbian/build version for a single run: `ARMBIAN_REF=main docker compose run --rm build ...`
- The repository is checked out with LF line endings regardless of `core.autocrlf` (see `.gitattributes`).

### Updating Armbian

1. Change `ARMBIAN_REF` to the new release branch (`git ls-remote --heads https://github.com/armbian/build 'v*'`).
2. If the new release moved sunxi U-Boot to another version, rename
   `userpatches/u-boot/v2026.07-sunxi` after `BOOTPATCHDIR` in
   `config/sources/families/include/sunxi_common.inc` and check that the patch still applies.
3. Build and boot-test the image.

### Updating an installed system

Kernel packages in the Armbian apt repository are built without the WuKong Pi device tree,
so the board would not boot after `apt upgrade` installed them. The image therefore has its
Armbian packages (kernel, DTB, U-Boot, BSP, firmware) on hold (`BSPFREEZE="yes"` in the board
config, see `apt-mark showhold`); Debian/Ubuntu packages are upgraded as usual. Update the kernel
by flashing a new image or by installing the `.deb` packages from `output/debs/` with `dpkg -i`.
