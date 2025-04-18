#
# musicbrainz-picard Dockerfile
#
# https://github.com/jlesage/docker-musicbrainz-picard
#

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.20-v4.7.1

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG PICARD_VERSION=2.13.3

# Define software download URLs.
ARG PICARD_URL=https://data.musicbrainz.org/pub/musicbrainz/picard/picard-${PICARD_VERSION}.tar.gz

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN \
    add-pkg \
        py3-qt5 \
        py3-pyaml \
        py3-mutagen \
        py3-jwt \
        py3-markdown \
        py3-fasteners \
        py3-six \
        py3-charset-normalizer \
        py3-dateutil \
        py3-numpy \
        libdiscid \
        chromaprint \
        # For optical drive listing.
        lsscsi \
        # Needed for dark mode support.
        adwaita-qt \
        # Need a font.
        font-croscore

# Install MusicBrainz Picard.
RUN \
    # Install packages needed by the build.
    add-pkg --virtual build-dependencies \
        build-base \
        python3-dev \
        py3-pip \
        gettext \
        curl \
        && \
    # Download the MusicBrainz Picard package.
    echo "Downloading MusicBrainz Picard..." && \
    mkdir /tmp/musicbrainz-picard && \
    curl -L -# ${PICARD_URL} | tar xz --strip 1 -C /tmp/musicbrainz-picard && \
    # Patch MusicBrainz Picard.
    echo "Patching MusicBrainz Picard..." && \
    sed-patch 's/self.disable_autoupdate = None/self.disable_autoupdate = True/' /tmp/musicbrainz-picard/setup.py && \
    sed-patch "s/TextOption('setting', 'ui_theme', str(UiTheme.DEFAULT)),/TextOption('setting', 'ui_theme', str(UiTheme.SYSTEM)),/" /tmp/musicbrainz-picard/picard/ui/options/interface.py && \
    # Compile MusicBrainz Picard.
    echo "Compiling MusicBrainz Picard..." && \
    cd /tmp/musicbrainz-picard && \
    pip install --break-system-packages . && \
    # Needed by the BPM Analyzer plugin.
    pip install --break-system-packages aubio && \
    cd /tmp && \
    # Cleanup.
    del-pkg build-dependencies && \
    rm -rf /tmp/* /tmp/.[!.]*

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/musicbrainz-picard-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "MusicBrainz Picard" && \
    set-cont-env APP_VERSION "$PICARD_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
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
