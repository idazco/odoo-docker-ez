#!/usr/bin/env bash
cd "$(dirname "$0")"

# Download Community Edition if the download folder does not have a .deb file in it
if [ ! -f download/odoo.deb ]; then
	ODOO_VERSION="10.0"
	ODOO_RELEASE="20170815"
	echo "Downloading Odoo CE version $ODOO_VERSION release $ODOO_RELEASE"
	curl -o download/odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb
	echo '08d21e6419a72be7a3ad784df7a6fc8a46bbe7d9 download/odoo.deb' | sha1sum -c -
fi

# Build the image
echo "Building image"
docker build -t idazco/odoo10 .