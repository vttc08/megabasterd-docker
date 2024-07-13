#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure mandatory directories exist.
mkdir -p /config/logs

# Set default configuration on new install.
if [ ! -f /config/MegaBasterd/MegaBasterd.run ]; then
    cp -r /defaults/MegaBasterd /config
fi

# Create a file to indicate that MegaBasterd is running in portable mode.
if [ ! -f /config/MegaBasterd/jar/.megabasterd_portable ]; then
    echo "Portable file not found, creating..."
    touch /config/MegaBasterd/jar/.megabasterd_portable
fi

# Take ownership of the output directory.
take-ownership --not-recursive /output
take-ownership /config

# vim:ft=sh:ts=4:sw=4:et:sts=4
