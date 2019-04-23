#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Starting Odoo at https://localhost and http://localhost:8069"
docker-compose up
