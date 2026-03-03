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
