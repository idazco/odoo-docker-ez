#!/usr/bin/env bash
cd "$(dirname "$0")"

ODOO_VERSION="10.0"
ODOO_RELEASE="20170815"
DOWNLOAD_NAME="odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb"

# Download Community Edition if the download folder does not have a .deb file in it
if [ ! -f download/"$DOWNLOAD_NAME" ]; then
	echo "Downloading Odoo CE version $ODOO_VERSION release $ODOO_RELEASE to download/$DOWNLOAD_NAME"
	curl -o download/"$DOWNLOAD_NAME" -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb
	echo "08d21e6419a72be7a3ad784df7a6fc8a46bbe7d9 download/odoo_$DOWNLOAD_NAME" | sha1sum -c -
fi

SUFFIX=""
if [ "$1" = "ENTERPRISE" ]; then
	SUFFIX="e"
else
	cd download
	ln -s "$DOWNLOAD_NAME" odoo.deb
	cd ../
fi

# Build the image
echo "Building image"
docker build -t sylnsr/odoo10"$SUFFIX" .