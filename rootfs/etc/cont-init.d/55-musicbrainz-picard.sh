#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Install default config if needed.
[ -f /config/Picard.ini ] || cp -v /defaults/Picard.ini /config/Picard.ini

# vim:ts=4:sw=4:et:sts=4
