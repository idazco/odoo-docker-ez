#!/usr/bin/env bash
cd "$(dirname "$0")"
docker-compose up
echo "http://localhost:8080"