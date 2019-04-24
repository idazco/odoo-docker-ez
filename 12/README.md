# Docker-EZ for Odoo 12

## Note regarding the PG Client Tools:

As of the time of writing this documentation, this build is [compatible with Postgres v 10.0](https://github.com/odoo/odoo/issues/27447) and we pre-install the PG client tools for that version.

## HA-Proxy:

 - Be sure to change `change_this_password` in haproxy.cfg.example before deploying for real world use.