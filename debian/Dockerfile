FROM ghcr.io/loong64/debian:trixie-slim AS build-lat
ARG TARGETARCH

ARG DEPENDENCIES="        \
        ccache            \
        curl              \
        gcc               \
        git               \
        g++               \
        libc6             \
        libdrm-dev        \
        libglib2.0-dev    \
        libkeyutils-dev   \
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

ARG VERSION
ARG WORKDIR=/opt/lat

WORKDIR ${WORKDIR}

RUN set -ex \
    && git clone --depth=1 --recursive --branch master https://github.com/lat-opensource/lat ${WORKDIR}

ENV USE_CCACHE=1
ADD lat_loong64.patch /opt/lat_loong64.patch

RUN --mount=type=cache,target=/root/.cache/ccache \
    git apply /opt/lat_loong64.patch \
    && sed -i 's@rm -rf@# rm -rf@g' latxbuild/build-release-nw.sh \
    && cd latxbuild \
    && ./build-release-nw.sh

FROM ghcr.io/loong64/debian:trixie-slim
ARG TARGETARCH

WORKDIR /opt/dist

COPY --from=build-lat /opt/lat/lat-Debian-nw.tar.gz /opt/dist/

RUN sha256sum lat-Debian-nw.tar.gz > lat-Debian-nw.tar.gz.sha256sum

VOLUME /dist

CMD cp -rf /opt/dist/* /dist/