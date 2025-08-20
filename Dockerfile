ARG BASE_IMAGE=ghcr.io/loong64/debian:trixie-slim

FROM ${BASE_IMAGE} AS base
ARG TARGETARCH

ARG DEPENDENCIES="         \
        ccache             \
        curl               \
        devscripts         \
        equivs             \
        gcc                \
        git                \
        g++                \
        libc6              \
        libdrm-dev         \
        libglib2.0-dev     \
        libkeyutils-dev    \
        libssl-dev         \
        lsb-release        \
        make               \
        ninja-build        \
        pkg-config         \
        python3-setuptools \
        xz-utils"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y ${DEPENDENCIES}

ARG VERSION
ARG WORKDIR=/opt/lat

RUN set -ex \
    && git clone --depth=1 --recursive -b ${VERSION} https://github.com/lat-opensource/lat ${WORKDIR}

ENV USE_CCACHE=1
WORKDIR ${WORKDIR}

FROM base AS build-binary
ARG TARGETARCH

RUN --mount=type=cache,target=/root/.cache/ccache \
    set -x \
    && ./latxbuild/build-release.sh \
    && mkdir -p dist \
    && mv lat-${VERSION}-*.tar.xz dist/lat-${VERSION}-${TARGETARCH}.tar.xz \
    && cd dist \
    && sha256sum lat-${VERSION}-${TARGETARCH}.tar.xz > lat-${VERSION}-${TARGETARCH}.tar.xz.sha256

FROM base AS build-deb
ARG TARGETARCH

COPY debian .
RUN --mount=type=cache,target=/root/.cache/ccache \
    set -x \
    && dpkg-buildpackage -b -rfakeroot -us -uc \
    && cd .. \
    && rm -rf lat

FROM ghcr.io/loong64/debian:trixie-slim
ARG TARGETARCH

WORKDIR /opt/dist

COPY --from=build-deb /opt/ /opt/dist/
COPY --from=build-binary /opt/lat/dist/ /opt/dist/

VOLUME /dist

CMD cp -rf /opt/dist/* /dist/