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

git config --global --add safe.directory '*'

# output/, cache/ and .tmp are mount points inside ${SRC}, so it is never empty
# and `git clone` can't be used. They are in armbian/build's .gitignore, and
# `git clean` without -x leaves them alone.
echo "Checking out armbian/build ${ARMBIAN_REF}..."
[[ -d "${SRC}/.git" ]] || git init -q "${SRC}"
git -C "${SRC}" fetch --depth=1 --force "${ARMBIAN_REPO}" "${ARMBIAN_REF}"
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
