#!/bin/sh
set -e

DB_FILE=/config/MegaBasterd/jar/.megabasterd${VERSION}/megabasterd.db

if [ ! -f "$DB_FILE" ]; then
    echo "Database not found, creating..."
    mkdir -p /config/MegaBasterd/jar/.megabasterd${VERSION}
    touch "$DB_FILE"
fi

if [ ! -f /config/MegaBasterd/loaded ]; then
    echo "Settings signature not found, load settings..."
    apk add --no-cache sqlite
    touch "$DB_FILE"
    cat /defaults/config.sql | sqlite3 "$DB_FILE"
    touch /config/MegaBasterd/loaded
    apk del sqlite
    rm -rf /tmp/* /tmp/.[!.]*
else
    echo "Settings signature found, skipping load settings."
fi
