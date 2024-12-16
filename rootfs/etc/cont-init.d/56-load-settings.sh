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
    if [ "$WARPSTACK" = "true" ]; then
        echo "WarpStack enabled, updating settings..."
        cat /defaults/warpstack.sql | sqlite3 "$DB_FILE"
        if [ ! -f /config/reset.sh ]; then
            echo "You chose WarpStack, but no reset script found, creating..."
            cat <<EOF > /config/reset.sh
#!/bin/sh
sleep 0 # implement your own VPN/Proxy reset script here
EOF
            chmod +x /config/reset.sh
        fi
    else
        echo "No WarpStack, use SmartProxy instead."
        cat /defaults/smartproxy.sql | sqlite3 "$DB_FILE"
    fi
    touch /config/MegaBasterd/loaded
    # For newer version of megabasterd the db file location changed
    if [ -d "/config/MegaBasterd/jar/.megabasterd" ]; then
        cp $DB_FILE /config/MegaBasterd/jar/.megabasterd/megabasterd.db
    fi
    apk del sqlite
    rm -rf /tmp/* /tmp/.[!.]*
else
    echo "Settings signature found, skipping load settings."
fi
