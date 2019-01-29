FROM debian:jessie
MAINTAINER IDAZCO


######
# tini
######
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini


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
			git \
		&& pip install -U pip setuptools \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* wkhtmltox.deb \
        && export PYTHONIOENCODING=UTF-8 \
        && locale-gen en_US.UTF-8 \
        && mkdir /opt/odoo \
        && adduser --disabled-password --gecos "" odoo \
        && chown -R odoo:odoo /opt/odoo


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
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# phantomjs is needed in testing the UI
COPY resources/phantomjs* /tmp/phantomjs.tar.bz2
RUN tar xf /tmp/phantomjs.tar.bz2 -C /tmp/ \
	&& mv /tmp/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin \
	&& phantomjs --version


##################
# Copy and config
##################
COPY download/odoo-10.0 /opt/odoo/
COPY download/addons/selected /mnt/extra-addons/
COPY nginx.conf /etc/nginx/nginx.conf
COPY run-demo.conf /etc/odoo/odoo.conf
COPY entrypoint.sh /
COPY requirements.txt /tmp/requirements.txt
# fix encoding issue
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
# install requirements and set permissions
RUN set -x; \
	mkdir -p /var/lib/odoo && \
	ln -s /opt/odoo/odoo-bin /usr/bin/odoo && \
	chown -R odoo:root /etc/odoo && \
	chown -R odoo:odoo /var/lib/odoo && \
	chown -R odoo:odoo /var/lib/nginx && \
    chown -R odoo:odoo /var/log/nginx && \
    pip install --upgrade pip && \
	pip install -r /opt/odoo/requirements.txt && \
	pip install -r /tmp/requirements.txt && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


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

ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
CMD ["/opt/odoo/odoo-bin"]