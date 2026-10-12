#
# musicbrainz-picard Dockerfile
#
# https://github.com/jlesage/docker-musicbrainz-picard
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG PICARD_VERSION=3.0.2

# Define software download URLs.
ARG PICARD_URL=https://data.musicbrainz.org/pub/musicbrainz/picard/picard-${PICARD_VERSION}.tar.gz

# Get Dockerfile cross-compilation helpers.
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

# Get UPX (statically linked).
# NOTE: UPX 5.x is not compatible with old kernels (e.g. 3.10) used by some
#       Synology NASes. See https://github.com/upx/upx/issues/902
FROM --platform=$BUILDPLATFORM alpine:3.20 AS upx
ARG UPX_VERSION=4.2.4
RUN \
    if echo "${UPX_VERSION}" | grep -q '^[0-9]\+\.[0-9]\+\.[0-9]\+$'; then \
        apk --no-cache add curl && \
        mkdir /tmp/upx && \
        curl -# -L https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-amd64_linux.tar.xz | tar xJ --strip 1 -C /tmp/upx && \
        cp -v /tmp/upx/upx /usr/bin/upx; \
    else \
        apk --no-cache add build-base cmake clang git && \
        git clone https://github.com/upx/upx.git && \
        git -C upx reset --hard ${UPX_VERSION} && \
        git -C upx submodule update --init && \
        make -C upx build/extra/gcc/all CC="clang" CXX="clang++" CFLAGS="-static" CXXFLAGS="-static" LDFLAGS="-Wl,--strip-all" && \
        cp -v upx/build/extra/gcc/release/upx /usr/bin/upx; \
    fi

# Build MusicBrainz Picard.
FROM alpine:3.24 AS picard
ARG PICARD_URL
COPY src/picard /build
RUN /build/build.sh "$PICARD_URL"

# Build fileurl2path.
FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS fileurl2path
ARG TARGETPLATFORM
ENV CGO_ENABLED=0
COPY --from=xx / /
COPY src/fileurl2path /tmp/build-fileurl2path
RUN cd /tmp/build-fileurl2path && xx-go build -ldflags "-s -w"
RUN xx-verify --static /tmp/build-fileurl2path/fileurl2path
COPY --from=upx /usr/bin/upx /usr/bin/upx
RUN upx /tmp/build-fileurl2path/fileurl2path

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.24-v4.14.0

ARG PICARD_VERSION
ARG DOCKER_IMAGE_VERSION

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN \
    add-pkg \
        py3-qt6 \
        py3-yaml \
        py3-mutagen \
        py3-jwt \
        py3-markdown \
        py3-charset-normalizer \
        py3-tomlkit \
        py3-pygit2 \
        libdiscid \
        chromaprint \
        rsgain \
        # For optical drive listing.
        lsscsi \
        # Needed for dark mode support.
        adwaita-qt6 \
        # A browser is needed.
        firefox-esr \
        # dbus is needed to allow multiple Firefox windows using the same
        # profile.
        dbus \
        # To play media files via external player.
        ffmpeg \
        ffplay \
        # To play media files via internal player.
        qt6-qtmultimedia-gstreamer \
        gst-plugins-good \
        # Need a font.
        font-croscore

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/musicbrainz-picard-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=picard /tmp/picard-install/usr/ /usr/
COPY --from=fileurl2path /tmp/build-fileurl2path/fileurl2path /usr/bin/

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "MusicBrainz Picard" && \
    set-cont-env APP_VERSION "$PICARD_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    set-cont-env DISABLE_GLX 1 && \
    true

# Define mountable directories.
VOLUME ["/storage"]

# Metadata.
LABEL \
    org.label-schema.name="musicbrainz-picard" \
    org.label-schema.description="Docker container for MusicBrainz Picard" \
    org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
    org.label-schema.vcs-url="https://github.com/jlesage/docker-musicbrainz-picard" \
    org.label-schema.schema-version="1.0"
