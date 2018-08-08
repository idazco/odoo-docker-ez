#!/usr/bin/env bash
cd "$(dirname "$0")"

ODOO_VERSION="10.0"
ODOO_RELEASE="20180122"
DOWNLOAD_NAME="odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb"
DOWNLOAD_HASH="836f0fb94aee0d3771cf2188309f6079ee35f83e"

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

read -p "Download (or re-download) extra addons? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# Download selected add-ons from other projects
	function clean_up () {
		rm -rf ./download/addons/tmp*
	}
	mkdir -p ./download/addons/selected
	clean_up
	function get_zip_file_from_github () {
		curl -L -o ./download/addons/tmp.zip $1
		unzip ./download/addons/tmp.zip -d ./download/addons/tmp
	}
	function clean_mv () {
		rm -rf ./download/addons/selected/$2
		mv ./download/addons/tmp$1/$2 ./download/addons/selected/$2
	}
	# from https://github.com/it-projects-llc/misc-addons
	URL="https://github.com/it-projects-llc/misc-addons/archive/10.0.zip"
	get_zip_file_from_github $URL
	clean_mv /misc-addons-10.0 base_session_store_psql
	clean_mv /misc-addons-10.0 ir_attachment_s3
	clean_mv /misc-addons-10.0 web_debranding
	# TODO: add other modules as needed
	clean_up
fi


# Build the image
echo "Building image"

read -p "Disable build cache? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    NO_BUILD_CACHE="--no-cache=true"
fi

echo
TARGET_REPO="idazco"
read -e -p "Target repo ---> " -i "$TARGET_REPO" TARGET_REPO
if [ -z "$TARGET_REPO" ]
then
	TARGET_REPO="idazco"
fi

COMMAND="docker build $NO_BUILD_CACHE -t $TARGET_REPO/odoo10:$TAG ."
echo "$COMMAND"
$COMMAND