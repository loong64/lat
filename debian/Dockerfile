FROM ghcr.io/loong64/debian:trixie-slim AS build-lat
ARG TARGETARCH

ARG DEPENDENCIES="         \
        ccache             \
        curl               \
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

WORKDIR ${WORKDIR}

ENV USE_CCACHE=1
RUN --mount=type=cache,target=/root/.cache/ccache \
    set -x \
    && ./latxbuild/build-release.sh \
    && mkdir -p dist \
    && mv lat-${VERSION}-*.tar.xz dist/lat-${VERSION}-${TARGETARCH}.tar.xz \
    && cd dist \
    && sha256sum lat-${VERSION}-${TARGETARCH}.tar.xz > lat-${VERSION}-${TARGETARCH}.tar.xz.sha256

FROM ghcr.io/loong64/debian:trixie-slim
ARG TARGETARCH

WORKDIR /opt/dist

COPY --from=build-lat /opt/lat/dist/ /opt/dist/

VOLUME /dist

CMD cp -rf /opt/dist/* /dist/