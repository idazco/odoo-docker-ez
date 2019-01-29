#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Starting Odoo at http://localhost:8080"
docker-compose up
