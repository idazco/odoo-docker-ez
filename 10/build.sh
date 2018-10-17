#!/usr/bin/env bash
cd "$(dirname "$0")"

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


# https://github.com/it-projects-llc
read -p "Get / refresh addons from https://github.com/it-projects-llc? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	URL="https://github.com/it-projects-llc/misc-addons/archive/10.0.zip"
	get_zip_file_from_github $URL
	clean_mv /misc-addons-10.0 web_debranding
	# TODO: copy other modules as needed
	clean_up
	echo
fi


# https://github.com/odoo/odoo-extra
read -p "Get / refresh addons from https://github.com/odoo/odoo-extra? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	URL="https://github.com/odoo/odoo-extra/archive/10.0.zip"
	get_zip_file_from_github $URL
	clean_mv /odoo-extra-10.0 session_db
	clean_up
	echo
fi


read -p "Disable build cache? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    NO_BUILD_CACHE="--no-cache=true"
    echo
fi

TARGET_REPO="idazco"
read -e -p "Target repo ---> " -i "$TARGET_REPO" TARGET_REPO
if [ -z "$TARGET_REPO" ]
then
	TARGET_REPO="idazco"
fi

COMMAND="docker build $NO_BUILD_CACHE -t $TARGET_REPO/odoo10 ."
echo "$COMMAND"
$COMMAND
echo
echo "Push command:"
echo "docker push $TARGET_REPO/odoo10"