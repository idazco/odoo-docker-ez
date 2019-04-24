#!/usr/bin/env bash
cd "$(dirname "$0")"
mkdir -p ./var-lib-odoo
chmod 777 ./var-lib-odoo
echo "Starting Odoo at https://localhost and http://localhost:8069"
docker-compose up
