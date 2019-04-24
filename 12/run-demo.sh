#!/usr/bin/env bash
cd "$(dirname "$0")"
mkdir -p ./var-lib-odoo
sudo find ./var-lib-odoo/ -type d -exec chmod 777 {} \;
echo "Starting Odoo at https://localhost and http://localhost:8069"
docker-compose up
