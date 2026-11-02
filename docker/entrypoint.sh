#!/bin/bash
# This repository only carries the WuKong Pi board support (userpatches/), the
# framework itself is armbian/build at the ref from ARMBIAN_REF. It is checked
# out on a Linux volume (Windows paths are too short for its patch names and a
# Windows checkout has no symlinks), userpatches/ is copied next to it.
# output/ is bind-mounted straight through, see docker-compose.yml.
set -e

SRC=/root/armbian
ARMBIAN_REPO=${ARMBIAN_REPO:-https://github.com/armbian/build.git}
ARMBIAN_REF=${ARMBIAN_REF:-$(tr -d '[:space:]' < /src/ARMBIAN_REF)}

# Docker Desktop's DNS intermittently returns empty answers under load, so git,
# wget and debootstrap fail at random. Cache lookups so each host is resolved once.
upstream=$(awk '/^nameserver/ { print $2; exit }' /etc/resolv.conf)
dnsmasq --listen-address=127.0.0.1 --bind-interfaces --no-resolv --server="${upstream}" \
	--cache-size=10000 --min-cache-ttl=3600 --no-negcache --user=root
printf 'nameserver 127.0.0.1\noptions attempts:3 timeout:2\n' > /etc/resolv.conf

# The armhf rootfs is built through qemu-arm in binfmt_misc. Docker Desktop registers an ARM
# emulator in its VM, a plain Linux host (GitHub runner) usually doesn't, and the framework
# can't do it: it uses update-binfmts, but qemu-user-static 8.x only ships /usr/lib/binfmt.d
# entries. The entry has the F flag, so the kernel keeps the interpreter open and it works
# from any container; the registration is host-wide (binfmt_misc is not namespaced).
if ! arch-test armhf > /dev/null 2>&1; then
	echo "Registering qemu-arm in binfmt_misc"
	mountpoint -q /proc/sys/fs/binfmt_misc || mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
	cat /usr/lib/binfmt.d/qemu-arm.conf > /proc/sys/fs/binfmt_misc/register
	arch-test armhf
fi

git config --global --add safe.directory '*'

# output/, cache/ and .tmp are mount points inside ${SRC}, so it is never empty
# and `git clone` can't be used. They are in armbian/build's .gitignore, and
# `git clean` without -x leaves them alone.
echo "Checking out armbian/build ${ARMBIAN_REF}..."
[[ -d "${SRC}/.git" ]] || git init -q "${SRC}"
# the framework reads the remote URL for the build metadata
git -C "${SRC}" remote add origin "${ARMBIAN_REPO}" 2> /dev/null || git -C "${SRC}" remote set-url origin "${ARMBIAN_REPO}"
git -C "${SRC}" fetch --depth=1 --force origin "${ARMBIAN_REF}"
git -C "${SRC}" checkout -q --force --detach FETCH_HEAD
git -C "${SRC}" clean -q -d --force
git -C "${SRC}" log -1 --format='armbian/build %h (%cs) %s'

# The board DTS is the same for every kernel branch: put it into the dt_32 dir of
# each sunxi kernel patch set, the framework adds it to the DT Makefile itself.
rsync -a --delete /src/userpatches/ "${SRC}"/userpatches/
for dir in "${SRC}"/patch/kernel/archive/sunxi-*/; do
	dt_dir="${SRC}/userpatches/kernel/archive/$(basename "${dir}")/dt_32"
	mkdir -p "${dt_dir}"
	cp /src/userpatches/kernel/sunxi-dt_32/*.dts "${dt_dir}"/
done

cd "${SRC}"
if [[ "$1" == bash || "$1" == shell ]]; then
	exec /bin/bash
fi
exec /bin/bash "${SRC}"/compile.sh "$@"
