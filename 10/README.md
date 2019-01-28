# Docker-EZ for Odoo 10

## PG Client (v9.6):

This build assumes you are using Postgres v9.6 and installs the client tools for that version.
You should alter the Dockerfile if you need the PG client for a different version. This is needed
for backups to work properly when they are initiated using the Odoo UI and run within the container,
which is actually not recommended, just instead, provided just so that, that UI is not broken.
