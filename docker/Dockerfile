# Build environment for armbian/build (used by docker-compose.yml in the repo root).
# Based on the image Armbian's own Docker mode uses: host dependencies of the
# framework are preinstalled, so prepare_host does not hit apt on every run.
# dnsmasq-base and rsync are for docker/entrypoint.sh.
FROM ghcr.io/armbian/docker-armbian-build:armbian-ubuntu-noble-latest

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends dnsmasq-base git rsync \
    && rm -rf /var/lib/apt/lists/*

ENV ARMBIAN_RUNNING_IN_CONTAINER=yes LANG=C.UTF-8 TERM=screen

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /root/armbian
ENTRYPOINT [ "/bin/bash", "/usr/local/bin/entrypoint.sh" ]
