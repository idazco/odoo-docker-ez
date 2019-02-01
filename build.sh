#!/usr/bin/env bash
cd "$(dirname "$0")"

VER=$1

if [[ $VER == "10" || $VER == "12" ]]; then
	echo "Building version $VER"
	cd "./$VER"
else
	echo "Usage:"
	echo "------"
	echo "$ build.sh <version>"
	echo ""
	echo "Params:"
	echo "------"
	echo "version :  Must be 10 or 12"
	exit 1
fi

# prepare selected add-ons
mkdir -p ./download/addons/selected


#========
# Download selected add-ons from other projects
function clean_up () {
	rm -rf ./download/addons/tmp*
}
clean_up
function get_zip_file_from_github () {
	curl -L -o ./download/addons/tmp.zip $1
	unzip ./download/addons/tmp.zip -d ./download/addons/tmp
}
function clean_mv () {
	rm -rf ./download/addons/selected/$2
	mv ./download/addons/tmp$1/$2 ./download/addons/selected/$2
}
#========


# Odoo source
read -p "Get / refresh Odoo source (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
	URL="https://github.com/odoo/odoo/archive/$VER.0.zip"
	curl -L -o ./download/tmp.zip $URL
	unzip ./download/tmp.zip -d ./download/
	rm ./download/tmp.zip
	REQS="./download/odoo-$VER.0/requirements.txt"
	echo "Adapting file $REQS"

	# prevent error when install this dep with Odoo 10
	if [[ $VER == "10" ]]; then
		# this is already installed
		sed -i '/PyYAML/d' $REQS

	# prevent error when install this dep with Odoo 12
	elif [[ $VER == "12" ]]; then
		# this is already installed
		sed -i '/pyldap/d' $REQS
	fi
	echo
fi

# https://github.com/it-projects-llc
read -p "Get / refresh addons from https://github.com/it-projects-llc? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	URL="https://github.com/it-projects-llc/misc-addons/archive/$VER.0.zip"
	SRC_DIR="/misc-addons-$VER.0"
	get_zip_file_from_github $URL
	clean_mv $SRC_DIR web_debranding
	clean_mv $SRC_DIR base_session_store_psql
	clean_mv $SRC_DIR ir_attachment_s3
	# TODO: copy other modules as needed
	clean_up
	echo
fi


#========
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

DATE=`date +%Y%m%d`
COMMAND="docker build $NO_BUILD_CACHE -t $TARGET_REPO/odoo:$VER-latest ."
echo "$COMMAND"
$COMMAND

if [ $? == 0 ]; then
	echo
	docker tag "$TARGET_REPO/odoo:$VER-latest" "$TARGET_REPO/odoo:$VER-$DATE"
	echo "Push commands:"
	echo "docker push $TARGET_REPO/odoo:$VER-latest"
	echo "docker push $TARGET_REPO/odoo:$VER""_$DATE"
else
	echo "Error!"
	exit 2
fi

cd ../