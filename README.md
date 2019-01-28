# odoo-docker-ez

## Supported Versions

I don't believe its practical to upgrade our deployments to every new version Odoo, but instead I upgrade even versions only. So currently this project is being developed and maintained for even versions of Odoo starting from v10. If I get a use case to support v11 or any other odd-numbered version, I'll do it.

## Project Goals

 - Provide a simple way to build Docker Odoo images
 - Make the images as complete as possible so that, for most use cases, things just work without additional effort

## Whats special about our build

 - Nginx reverse proxy is already part of the image and configured so that certain modules which require it, will work, for example, the Discuss (chat) module.
 - I pre-install dependencies so that if certain standard/common modules are installed that need them, they are already there. 

<hr>

# Instructions

## Building an Enterprise edition Docker image

 1. Login to your Odoo account and download the Debian installer package for Enterprise edition to the `download` folder in this project. The downloaded file should be named `odoo_10.0+e.latest_all.deb`
 1. Run the `build-enterprise.sh` bash script

## Building a Community edition Docker image

Just run the `build.sh` script
 
## Running a demo instance using with Community edition

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