FROM debian:jessie
MAINTAINER IDAZCO

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            unzip \
            wget \
            node-less \
            python-gevent \
            python-pip \
            python-renderpm \
            python-support \
            python-watchdog \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
        && pip install psycogreen==1.0

ADD "download/odoo.deb" /tmp/odoo.deb
RUN set -x; \
        dpkg --force-depends -i /tmp/odoo.deb \
        && apt-get update \
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* /tmp/odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
RUN chown odoo:root /etc/odoo/odoo.conf

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
        && chown -R odoo:root /var/lib/odoo \
        && chown -R odoo:root /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

####################################
# Install additional deps and tools:
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
        	build-essential \
        	autoconf \
        	libssl-dev \
        	libffi-dev \
        	libtool \
        	python-dev \
        	nano \
        	net-tools

# 3rd party Python depencencies installed from requirements.txt
ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Install NGINX ~ documentation does not tell you that certain Odoo
# modules cannot work properly unless Odoo is proxied through nginx
# certain way, by setting certain headers
RUN set -x; \
		apt-get update && \
		apt-get install -y nginx && \
		rm -rf /var/lib/apt/lists/* && \
		chown -R odoo:odoo /var/lib/nginx && \
		chown -R odoo:odoo /var/log/nginx
ADD nginx.conf /etc/nginx/nginx.conf

# Use tini to run nginx and odoo
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

# make sure the entry point file is executable
RUN chmod +x /entrypoint.sh

# the Docker healthcheck command
HEALTHCHECK CMD curl --fail http://127.0.0.1:8069/web/database/selector || exit 1

# Expose nginx
EXPOSE 8080

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
CMD ["odoo"]