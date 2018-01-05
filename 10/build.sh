#!/usr/bin/env bash
cd "$(dirname "$0")"

ODOO_VERSION="10.0"
ODOO_RELEASE="20171030"
DOWNLOAD_NAME="odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb"
DOWNLOAD_HASH="b250b2bbcda6056146d323eb0d7a1e609a09d0ec"

# Download Community Edition if the download folder does not have a .deb file in it
if [ ! -f download/"$DOWNLOAD_NAME" ]; then
	echo "Downloading Odoo CE version $ODOO_VERSION release $ODOO_RELEASE to download/$DOWNLOAD_NAME"
	curl -o download/"$DOWNLOAD_NAME" -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb
	echo "DOWNLOAD_HASH download/odoo_$DOWNLOAD_NAME" | sha1sum -c -
fi

TAG="community"
if [ "$1" = "ENTERPRISE" ]; then
	TAG="enterprise"
elif [ ! -f download/odoo.deb ]; then
	cd download
	ln -s "$DOWNLOAD_NAME" odoo.deb
	cd ../
fi

# Build the image
echo "Building image"

read -p "Disable build cache? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    NO_BUILD_CACHE="--no-cache=true"
fi


TARGET_REPO="idazco"
read -e -p "Target repo ---> " -i "$TARGET_REPO" TARGET_REPO
if [ -z "$TARGET_REPO" ]
then
	TARGET_REPO="idazco"
fi

COMMAND="docker build $NO_BUILD_CACHE -t $TARGET_REPO/odoo10:$TAG ."
echo "$COMMAND"
$COMMAND