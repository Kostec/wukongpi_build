# wukongpi_build

### Basic requirements

- x86_64 or aarch64 machine with at least 2GB of memory and ~35GB of disk space for a virtual machine, container or bare metal installation
- Ubuntu Jammy 22.04.x amd64 or aarch64 for native building 
- Superuser rights (configured sudo or root access).

### Simply start with the build script

```bash
apt-get -y install git
git clone https://github.com/Timfu2019/wukongpi_build.git
cd build
./compile.sh
```
or
```
./compile.sh  BOARD=wukongpi BRANCH=current BUILD_MINIMAL=no BUILD_DESKTOP=no BUILD_ONLY=u-boot,kernel,armbian-config,armbian-zsh,plymouth-theme-armbian,armbian-firmware,armbian-bsp KERNEL_CONFIGURE=no
```

### Release

Select the userspace with `RELEASE=`: `jammy`, `noble` (Ubuntu 24.04), `bullseye`, `bookworm` or `trixie` (Debian 13).
In the interactive menu `bookworm` is shown only with `EXPERT=yes`.

```
./compile.sh BOARD=wukongpi BRANCH=current RELEASE=trixie BUILD_MINIMAL=no BUILD_DESKTOP=no KERNEL_CONFIGURE=no
```

### Building on Windows (Docker)

Requirements: Docker Desktop with the WSL 2 backend, switched to **Linux containers**
(tray icon → "Switch to Linux containers...").

```
docker compose build
docker compose run --rm build BOARD=wukongpi BRANCH=current RELEASE=trixie BUILD_MINIMAL=no BUILD_DESKTOP=no KERNEL_CONFIGURE=no
```

- `docker compose run --rm build` without arguments opens the interactive menu.
- `docker compose run --rm build shell` gives a shell in the build environment.
- Results are written to `output/`, `userpatches/` is used as is. The build runs from a copy of the
  sources on the `armbian-src` volume, synced on every start: a Windows checkout turns git symlinks
  into plain text files, and the copy gets them back from the git index (`docker/entrypoint.sh`).
- Downloaded sources, the rootfs cache and ccache are kept in the Docker volumes `armbian-cache`,
  `armbian-tmp` and `armbian-ccache` (`docker compose down -v` deletes them).
- The repository is checked out with LF line endings regardless of `core.autocrlf` (see `.gitattributes`).
  If a build fails with `$'\r': command not found`, re-clone the repository.
- For faster builds clone the repository inside the WSL 2 filesystem (e.g. `\\wsl$\Ubuntu\home\...`)
  and run the same commands there.
