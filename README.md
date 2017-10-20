# odoo-enterprise-dockerfile

A Dockerfile for Odoo 10 Enterprise image building.

## NOTE:
This does NOT include any Odoo Enterprise modules. You will need to buy a valid Enterprise license and [download](https://www.odoo.com/page/download) the Debian installer package (odoo_10.0+e.latest_all.deb) to the `/resources` folder. The Dockerfile will then use the Debian installer package to install Odoo Enterprise edition from that folder.

## How this project differs from https://github.com/odoo/docker

 1. Instead of installing Community edition from http://nightly.odoo.com, the Dockerfile will install the Enterprise edition from the Debian package which *YOU* must download to the `/resources` folder  
 1. I currently just support version 10. When I start doing work related to version 11 I will add it.
 
## Directions

 1. Login to your Odoo account and download the Debian installer package
 1. Download the Debian installer to the appropriate `/resources` folder
 1. Run the `build.sh` file
 
### Optional

Re-tag the built image to whatever you want to call it and upload it your *private* repo.
For example:

	docker tag odoo10e mydockerorg/odoo10e
	docker push mydockerorg/odoo10e
