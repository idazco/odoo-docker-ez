FROM debian:stretch
MAINTAINER IDAZCO

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            gcc \
            libssl1.0-dev \
            node-less \
            python3-pip \
            python3-dev \
            python3-wheel \
            python3-venv \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-vobject \
            python3-watchdog \
            build-essential \
            xz-utils \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
        && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb\
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb  \
		&& mkdir /opt/odoo \
		&& adduser --disabled-password --gecos "" odoo \
		&& mkdir -p /var/lib/odoo


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


# Install rtlcss (on Debian stretch)
RUN set -x;\
    echo "deb http://deb.nodesource.com/node_8.x stretch main" > /etc/apt/sources.list.d/nodesource.list \
    && export GNUPGHOME="$(mktemp -d)" \
    && repokey='9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --armor --export "${repokey}" | apt-key add - \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g rtlcss \
    && rm -rf /var/lib/apt/lists/*


# Install Odoo
ENV ODOO_VERSION 12.0
ARG ODOO_RELEASE=20190424
ARG ODOO_SHA=3885be6791b9b8c2a74115299e57213c71db4363
RUN set -x; \
	curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
	&& echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
	&& dpkg --force-depends -i odoo.deb \
	&& apt-get update \
	&& apt-get -y install -f --no-install-recommends \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* odoo.deb


###############
# Other add-ons
###############
COPY download/addons/selected /mnt/extra-addons/
COPY requirements.txt /tmp/requirements.txt
RUN set -x; \
	chown -R odoo:odoo /var/lib/odoo && \
	pip3 install wheel && \
	pip3 install -r /tmp/requirements.txt && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Entrypoint; Odoo config; chown / chmod
COPY ./entrypoint.sh /
COPY run-demo.conf /etc/odoo/odoo.conf
RUN pip3 install num2words xlwt \
	&& chown odoo /etc/odoo/odoo.conf \
	&& chown odoo /entrypoint.sh \
	&& chmod +x /entrypoint.sh \
    && chown -R odoo /mnt/extra-addons


##########
# Startup
##########
# the Docker healthcheck command
HEALTHCHECK CMD curl --fail http://127.0.0.1:8069/web/webclient/locale/en_US || exit 1

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

RUN export PYTHONIOENCODING=UTF-8

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]