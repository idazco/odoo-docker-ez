FROM odoo:12
MAINTAINER IDAZCO
USER root

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

######
# tini
######
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini


#####################
# Deps & permissions
#####################
COPY download/addons/selected /mnt/extra-addons/
RUN set -x; apt update && apt install -y \
 	nginx \
	&& rm -rf /var/lib/apt/lists/* /var/tmp/* \
	&& chown odoo:root /etc/odoo


##############
# Deps config
##############
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /
RUN set -x; \
	chown -R odoo:odoo /var/lib/nginx \
	&& chown -R odoo:odoo /var/log/nginx


#############
# PG client
#############
# This release works with Postgres 10.0 so make sure we have the right PG tools
RUN DEBIAN_FRONTEND=noninteractive \
    cd /tmp && \
    apt-get update && \
    apt-get install -y gnupg2 && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc -o ACCC4CF8.asc && \
    apt-key add ACCC4CF8.asc && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql-client-10 && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


##########
# Startup
##########
# make sure the entry point file is executable
RUN chmod +x /entrypoint.sh

# the Docker healthcheck command
#HEALTHCHECK CMD curl --fail http://127.0.0.1:8069/web_editor/static/src/xml/ace.xml || exit 1

# Expose proxy
EXPOSE 8080

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
CMD ["odoo"]