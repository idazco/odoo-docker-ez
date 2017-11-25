# odoo-docker-ez

## Project Goals

 - Provide a simple way to build Docker Odoo images
 - Make the images as complete as possible so that, for most use cases, things just work without additional effort

## Whats special about our build

 - Nginx reverse proxy is already part of the image and configured so that certain modules which require it, will work, for example, the Discuss (chat) module.
 - We pre-install dependencies so that if certain standard/common modules are installed that need them, they are already there. 

<hr>

# Instructions

## Building an Enterprise edition Docker image

 1. Login to your Odoo account and download the Debian installer package for Enterprise edition to the `download` folder in this project.
 1. Rename the downloaded file to `odoo.deb`
 1. Run the `build.sh` bash script

## Building a Community edition Docker image

Just run the `build.sh` script
 
## Running a demo instance using with Community edition

Just run the `run-demo` script. This will build the default image then run docker-compose to launch a database container and the Odoo container.

The app can be accessed at http://localhost:8080. The "Master Password" is `odoo_admin`.

# Configuration

Refer to the Odoo documentation for correct configuration options. You can refer to the [run-demo.conf](10/run-demo.conf) file for a basic configuration example. Because this project will include an nginx reverse proxy, the config file you use **MUST** have the following:

	longpolling_port = 8072
    reverse_proxy = True

Additionally, if you are going to use features that require running an "evented" instance of Odoo, such as the Discuss module, then you **MUST** set `workers` to a value greater than zero.

<hr>

# Compatibility

 - Tested with `docker` 17 CE
 - Tested with `docker-compose` 1.17

<hr>

# Additional notes

Re-tag the built image to whatever you want to call it and upload it your own Docker repo.
For example:

	docker tag idazco/odoo10 your-dockerhub-org/odoo10
	docker push your-dockerhub-org/odoo10

If you build an Enterprise edition image, make sure to upload it to a **private** repo.

Running the demo uses Postgres 9.5, but you should be able to use Postgres 9.6 without any issues.