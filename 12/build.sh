#!/usr/bin/env bash
cd "$(dirname "$0")"

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


# https://github.com/it-projects-llc
read -p "Get / refresh addons from https://github.com/it-projects-llc? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	URL="https://github.com/it-projects-llc/misc-addons/archive/12.0.zip"
	get_zip_file_from_github $URL
	clean_mv /misc-addons-12.0 web_debranding
	# TODO: copy other modules as needed
	clean_up
	echo
fi


# https://github.com/odoo/odoo-extra
read -p "Get / refresh addons from https://github.com/odoo/odoo-extra? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	URL="https://github.com/odoo/odoo-extra/archive/12.0.zip"
	get_zip_file_from_github $URL
	clean_mv /odoo-extra-12.0 session_db
	clean_up
	echo
fi


# https://github.com/OCA/rest-framework
read -p "Get / refresh addons from https://github.com/OCA/rest-framework? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	URL="https://github.com/OCA/rest-framework/archive/12.0.zip"
	get_zip_file_from_github $URL
	clean_mv /rest-framework-12.0 base_rest
	clean_mv /rest-framework-12.0 base_rest_demo
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
COMMAND="docker build $NO_BUILD_CACHE -t $TARGET_REPO/odoo:12-latest ."
echo "$COMMAND"
$COMMAND
if [ $? == 0 ]; then
	echo
	docker tag "$TARGET_REPO/odoo:12-latest" "$TARGET_REPO/odoo:12-$DATE"
	echo "Push commands:"
	echo "docker push $TARGET_REPO/odoo:12-latest"
	echo "docker push $TARGET_REPO/odoo:12_$DATE"
else
	echo "Error!"
fi