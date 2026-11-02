#!/bin/bash
# Pre-downloads the shallow kernel git tarball that armbian/build otherwise pulls with ORAS.
# Through Docker Desktop's network the ORAS (HTTP/2) download of this ~300 MB blob breaks
# with "stream error: PROTOCOL_ERROR" and every retry starts from zero; curl over HTTP/1.1
# resumes instead. The framework skips the download when the tarball is already in the cache.
#
#   docker compose run --rm --entrypoint bash build /src/docker/fetch-kernel-git.sh 6.18
#
# The argument is KERNEL_MAJOR_MINOR of the branch to build (the build log prints it in
# "Using shallow Kernel bare tree for X.Y").
set -e -o pipefail

version=${1:?usage: $0 <kernel major.minor, e.g. 6.18>}
repo=armbian/shallow/kernel-git-shallow-${version}
dir=/root/armbian/cache/git-bundles/kernel
file=${dir}/linux-shallow-${version}.git.tar

# the framework deletes the tarball once it is extracted to the bare tree
if [[ -f "${file}" || -d "/root/armbian/cache/git-bare/shallow-kernel-${version}" ]]; then
	echo "Kernel ${version} git tree is already in the cache"
	exit 0
fi

curl_api() { curl -fsS --retry 5 --retry-all-errors "$@"; }
token() { curl_api "https://ghcr.io/token?scope=repository:${repo}:pull" | jq -er .token; }

digest=$(curl_api -H "Authorization: Bearer $(token)" \
	-H "Accept: application/vnd.oci.image.manifest.v1+json" \
	"https://ghcr.io/v2/${repo}/manifests/latest" | jq -er '.layers[0].digest')
echo "Downloading ${repo} (${digest})..."

mkdir -p "${dir}"
rm -rf "${file}.oras.pull.tmp"
for attempt in $(seq 1 40); do
	curl -sS --http1.1 -L -C - -H "Authorization: Bearer $(token)" -o "${file}.part" \
		"https://ghcr.io/v2/${repo}/blobs/${digest}" && break
	echo "attempt ${attempt} stopped at $(stat -c %s "${file}.part") bytes, resuming"
	sleep 3
done

echo "${digest#sha256:}  ${file}.part" | sha256sum -c -
mv "${file}.part" "${file}"
