#!/bin/bash
# The repository is bind-mounted at /src. A Windows checkout (core.symlinks=false)
# has no symlinks: git writes them as plain files holding the target path, which
# breaks config/cli/*, config/desktop/* and patch/kernel/*. So the build runs from
# a copy on a Linux volume where the symlinks are restored from the git index.
# output/ and userpatches/ are bind-mounted straight through, see docker-compose.yml.
set -e

SRC=/root/armbian

# Docker Desktop's DNS intermittently returns empty answers under load, so git,
# wget and debootstrap fail at random. Cache lookups so each host is resolved once.
upstream=$(awk '/^nameserver/ { print $2; exit }' /etc/resolv.conf)
dnsmasq --listen-address=127.0.0.1 --bind-interfaces --no-resolv --server="${upstream}" \
	--cache-size=10000 --min-cache-ttl=3600 --no-negcache --user=root
printf 'nameserver 127.0.0.1\noptions attempts:3 timeout:2\n' > /etc/resolv.conf

echo "Syncing sources to ${SRC}..."
rsync -a --delete \
	--exclude=/.git --exclude=/output --exclude=/userpatches --exclude=/cache --exclude=/.tmp \
	/src/ "${SRC}"/

git config --global --add safe.directory '*'
git -C /src ls-files -s | awk '$1 == "120000" { print $2, $4 }' | while read -r blob path; do
	[[ -L "${SRC}/${path}" ]] && continue
	rm -rf "${SRC:?}/${path}"
	ln -s "$(git -C /src cat-file blob "${blob}")" "${SRC}/${path}"
done

cd "${SRC}"
if [[ "$1" == bash || "$1" == shell ]]; then
	exec /bin/bash
fi
exec /bin/bash "${SRC}"/compile.sh "$@"
