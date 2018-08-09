FROM debian:jessie
MAINTAINER IDAZCO


RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            unzip \
            node-less \
            python-pip \
            python-renderpm \
            python-support \
            python-watchdog \
            libxml2-dev \
            libxslt-dev \
            libsasl2-dev \
            python-dev \
            libldap2-dev \
            libssl-dev \
			build-essential \
			autoconf \
			libssl-dev \
			libffi-dev \
			libtool \
			libpq-dev \
			nginx \
			locales \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* wkhtmltox.deb \
        && export PYTHONIOENCODING=UTF-8 \
        && locale-gen en_US.UTF-8 \
        && curl https://nightly.odoo.com/odoo.key -o odoo10key \
		&& apt-key add odoo10key && rm odoo10key \
		&& echo "deb http://nightly.odoo.com/10.0/nightly/deb/ ./" >> /etc/apt/sources.list.d/odoo.list


######
# tini
######
ENV TINI_VERSION v0.9.0
RUN set -x \
	&& curl -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini" -o /usr/local/bin/tini \
	&& curl -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc" -o /usr/local/bin/tini.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
	&& gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
	&& rm -r "$GNUPGHOME" /usr/local/bin/tini.asc \
	&& chmod +x /usr/local/bin/tini \
	&& tini -h


#############
# PG client
#############
# Modern projects use Postgres 9.6 so make sure we have the PG tools for v9.6
# from https://github.com/frodenas/docker-postgresql/blob/master/Dockerfile#L4
# However, if your project uses an older version, just set PG_VERSION here:
ENV PG_VERSION 9.6
RUN DEBIAN_FRONTEND=noninteractive \
    cd /tmp && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc -o ACCC4CF8.asc && \
    apt-key add ACCC4CF8.asc && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y --force-yes \
    postgresql-client-${PG_VERSION} && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


##############
# Copy files
##############
COPY download/addons/selected /mnt/extra-addons/
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /
COPY requirements.txt /tmp/requirements.txt


#############
# Odoo setup
#############
RUN set -x; pip install --upgrade -r /tmp/requirements.txt && rm /tmp/requirements.txt \
	&& apt-get update && apt-get -y install odoo \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& chown odoo:root /etc/odoo \
	&& chown -R odoo:root /var/lib/odoo \
	&& chown -R odoo:root /mnt/extra-addons \
	&& chown -R odoo:odoo /var/lib/nginx \
    && chown -R odoo:odoo /var/log/nginx

##########
# Startup
##########
# make sure the entry point file is executable
RUN chmod +x /entrypoint.sh

# the Docker healthcheck command
HEALTHCHECK CMD curl --fail http://127.0.0.1:8069/web_editor/static/src/xml/ace.xml || exit 1

# Expose proxy
EXPOSE 8080

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo
RUN export PYTHONIOENCODING=UTF-8

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
CMD ["odoo"]