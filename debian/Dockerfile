FROM ghcr.io/loong64/debian:trixie-slim AS build-lat
ARG TARGETARCH

# git ninja-build libssl-dev libc6 gcc g++ pkg-config libglib2.0-dev libdrm-dev lsb-release make python3-setuptools
ARG DEPENDENCIES="        \
        curl              \
        gcc               \
        git               \
        g++               \
        libc6             \
        libdrm-dev        \
        libglib2.0-dev    \
        libssl-dev        \
        lsb-release       \
        make              \
        ninja-build       \
        pkg-config        \
        python3-setuptools"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y ${DEPENDENCIES}

ARG VERSION=master
ARG WORKDIR=/opt/lat

WORKDIR ${WORKDIR}

RUN set -ex \
    && git clone --depth=1 --recursive --branch ${VERSION} https://github.com/lat-opensource/lat ${WORKDIR} \
    && curl -sSL "https://github.com/lat-opensource/lat/commit/27026fb60dc1707962539d8887ee4a9e4fb7d3ed.patch" | git apply

RUN cd latxbuild && ./build-release-nw.sh

FROM ghcr.io/loong64/debian:trixie-slim
ARG TARGETARCH

WORKDIR /opt/dist

COPY --from=build-lat /opt/lat/lat-Debian-nw /opt/dist/lat-Debian-nw

RUN tar -czf lat-Debian-nw.tar.gz lat-Debian-nw

VOLUME /dist

CMD cp -rf /opt/dist/* /dist/