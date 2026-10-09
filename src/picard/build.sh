#!/bin/sh
#
# Build MusicBrainz Picard and the Python packages Alpine does not ship.
#

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Set same default compilation flags as abuild.
# Do not pass --strip-all: that removes the dynamic symbols Python extension
# modules need in order to load.
export CFLAGS="-Os -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,--as-needed"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() {
    echo ">>> $*"
}

PICARD_URL="${1:-}"

if [ -z "$PICARD_URL" ]; then
    log "ERROR: Picard URL missing."
    exit 1
fi

#
# Install required packages.
#
apk --no-cache add \
    build-base \
    curl \
    gettext \
    patch \
    py3-pip \
    python3 \
    python3-dev \

#
# Download sources.
#
log "Downloading MusicBrainz Picard..."
mkdir /tmp/picard
curl -# -L -f "$PICARD_URL" | tar xz --strip 1 -C /tmp/picard

#
# Compile MusicBrainz Picard.
#
log "Patching MusicBrainz Picard..."
patch -p1 -d /tmp/picard < "$SCRIPT_DIR"/qt-style-override-dark-mode.patch

log "Installing MusicBrainz Picard..."
# --no-deps keeps pip from replacing Alpine's PyQt6/pygit2 wheels, which
# are not usable on musl. Update checks are disabled at build time.
(
    cd /tmp/picard && \
    PICARD_DISABLE_AUTOUPDATE=1 pip install \
        --break-system-packages \
        --no-deps \
        --root /tmp/picard-install \
        --prefix /usr \
        .
)

# python-discid is not packaged by Alpine. It is a ctypes wrapper around
# libdiscid.
log "Installing python-discid..."
pip install \
    --break-system-packages \
    --root /tmp/picard-install \
    --prefix /usr \
    'discid~=1.0'

# Replaced by the container's wrapper in rootfs.
rm -f /tmp/picard-install/usr/bin/picard-cli
