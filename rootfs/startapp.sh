#!/bin/sh
export HOME=/config
cd /storage
exec /usr/bin/picard --config-file /config/Picard.ini
# vim:ft=sh:ts=4:sw=4:et:sts=4
