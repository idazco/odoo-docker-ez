# odoo-docker-ez

A simple and complete way to build and run Odoo in Docker.

## Supported Versions

 10 and 12

## Whats different about our build

 - Nginx reverse proxy is already part of the version 10 image and configured so that certain modules which require it, will work, for example, the Discuss (chat) module. For version 12, we 
 use **haproxy with certbot** in a separate container instead and provide a setup in docker-compose.yml with a sample config.
 - I pre-install dependencies so that if certain standard/common modules are installed that need them, they are already there.
 - I pre-add certain useful modules that we seem to use often with certain clients that want high availability deployments.

<hr>

# Instructions

## Building an Enterprise edition Docker image

 1. Login to your Odoo account and download the Debian installer package for Enterprise edition to the `download` folder in this project. The downloaded file should be named `odoo_10.0+e.latest_all.deb`
 1. Run the `build-enterprise.sh` bash script

## Building a Community edition Docker image

Just run the `build.sh` script and pass in `10` or `12` as the param depending on which version of Odoo to build 
 
## Running a demo instance with Community edition

Just run the `run-demo` script. This will build the default image then run docker-compose to launch a database container and the Odoo container.

The app can be accessed at http://localhost:8080. The "Master Password" is `odoo_admin`.

# Configuration

Refer to the Odoo documentation for correct configuration options. You can refer to the [run-demo.conf](10/run-demo.conf) file for a basic configuration example. Because this project will include an nginx reverse proxy, the config file you use must not change the following:

	longpolling_port = 8072
    reverse_proxy = True

Additionally, if you are going to use features that require running an "evented" instance of Odoo, such as the Discuss module, then you **MUST** set `workers` to a value greater than zero.


<hr>

# Additional notes

 - [version 10](./10/README.md)
 - [version 12](./12/README.md)