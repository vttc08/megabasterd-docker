#!/bin/sh
if [ ! -f /config/MegaBasterd/jar/MegaBasterd.jar ]; then
    echo "Binary not found, downloading..."
    VERSION=${VERSION:-"8.21"} # latest working version of megabasterd
    DOWNLOAD_URL=https://github.com/tonikelope/megabasterd/releases/download/v${VERSION}/MegaBasterdLINUX_${VERSION}_portable.zip
    apk --no-cache add curl unzip
    mkdir -p /defaults
    cd /defaults
    curl -# -L -o /defaults/MegaBasterd.zip ${DOWNLOAD_URL}
    unzip -q MegaBasterd.zip
    mv MegaBasterdLINUX/ MegaBasterd
    rm -rf MegaBasterd/jre
    apk del curl unzip
    rm -rf Megabasterd.zip /tmp/* /tmp/.[!.]*
else
    echo "Binary found, skipping download."
fi
