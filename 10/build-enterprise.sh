#!/usr/bin/env bash
cd "$(dirname "$0")"

# Make sure user has downloaded Enterprise Edition
if [ ! -f download/odoo_10.0+e.latest_all.deb ]; then
	echo "Enterprise Edition installer not found."
	echo "First download odoo_10.0+e.latest_all.deb to the download folder"
	exit 1
fi

if [ -e download/odoo.deb ]; then
	rm download/odoo.deb
fi

cd download
ln -s odoo_10.0+e.latest_all.deb odoo.deb
cd ../

./build.sh ENTERPRISE

# remove the symlink so there is no confusion about which edition odoo.deb is for
rm download/odoo.deb