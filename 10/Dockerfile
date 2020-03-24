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
            openssl \
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
			wget \
		&& pip install -U pip setuptools \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.jessie_amd64.deb \
        && echo '4d104ff338dc2d2083457b3b1e9baab8ddf14202 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* wkhtmltox.deb \
        && export PYTHONIOENCODING=UTF-8 \
        && locale-gen en_US.UTF-8 \
        && adduser --disabled-password --gecos "" odoo


#############
# PG client
#############
RUN DEBIAN_FRONTEND=noninteractive \
    cd /tmp && \
    apt-get update && \
    apt-get install -y gnupg2 && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc -o ACCC4CF8.asc && \
    apt-key add ACCC4CF8.asc && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql-client-10 && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# phantomjs is needed in testing the UI
COPY resources/phantomjs* /tmp/phantomjs.tar.bz2
RUN tar xf /tmp/phantomjs.tar.bz2 -C /tmp/ \
	&& mv /tmp/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin \
	&& phantomjs --version


##################
# Copy and config
##################
RUN mkdir /etc/odoo
COPY download/addons/selected /mnt/extra-addons/
COPY nginx.conf /etc/nginx/nginx.conf
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
	chown -R odoo:root /etc/odoo && \
	chown -R odoo:odoo /var/lib/odoo && \
	chown -R odoo:odoo /var/lib/nginx && \
    chown -R odoo:odoo /var/log/nginx && \
    pip install --upgrade pip && \
	pip install -r /tmp/requirements.txt && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


##################
# Odoo installer
##################
RUN wget -O - https://nightly.odoo.com/odoo.key | apt-key add -
RUN echo "deb http://nightly.odoo.com/10.0/nightly/deb/ ./" >> /etc/apt/sources.list.d/odoo.list
RUN apt-get update \
	&& apt-get install -y odoo \
	&& ln -s /usr/lib/python2.7/dist-packages/odoo /opt
# replace the config
COPY run-demo.conf /etc/odoo/odoo.conf

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
CMD ["odoo"]