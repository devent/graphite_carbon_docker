FROM debian:8.6

# Configuration variables.
ENV DEBIAN_FRONTEND noninteractive
ENV WHISPER_VERSION 5ce9e80921cd8f33ab1797dc5781b0973c68d85c
ENV GRAPHITE_VERSION e76a8d6c1d3aacd7f4ef4099cc4cd5ffff4fd4f6
ENV CARBON_VERSION 2a9d92efaf43d4b696ac5c1ff40f019a0d81da2e

# Install tools and xmlstarlet to configure the Tomcat XML files.
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends \
        # python
        gcc \
        python-dev \
        python-pip \
        python-ldap \
        python-django \
        python-django-tagging \
        python-simplejson \
        python-memcache \
        python-pysqlite2 \
        python-tz \
        python-cairocffi \
        libffi-dev \
        # postgresql
        libpq-dev python-psycopg2 \
        # supervisor
        supervisor \
        # nginx
        nginx-light \
    && rm -rf /var/lib/apt/lists/*

# Install whitenoise.
RUN set -x \
    && pip install whitenoise==3.2.2

# Install whisper.
RUN set -x \
    && export PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/" \
    && pip install "https://github.com/graphite-project/whisper/archive/${WHISPER_VERSION}.zip"

# Install carbon.
RUN set -x \
    && export PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/" \
    && pip install "https://github.com/graphite-project/carbon/archive/${CARBON_VERSION}.zip"

# Install graphine.
RUN set -x \
    && export PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/" \
    && pip install "https://github.com/graphite-project/graphite-web/archive/${GRAPHITE_VERSION}.zip"

# Install gunicorn.
RUN set -x \
    && pip install gunicorn==19.6.0

# Whisper storage directory.
VOLUME /var/lib/graphite/storage/whisper

# Carbon line receiver port.
EXPOSE 2003

# Carbon pickle receiver port.
EXPOSE 2004

# Carbon cache query port.
EXPOSE 7002

# Gunicorn HTTP port.
EXPOSE 8000

# Nginx HTTP port.
EXPOSE 80

# Add entrypoint script.
COPY docker-entrypoint.sh /usr/local/bin/

# Set entrypoint script.
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Run supervisord.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# Add supervisor configuration.
COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/carbon_cache.conf /etc/supervisor/conf.d/
COPY supervisor/graphite_webapp.conf /etc/supervisor/conf.d/
COPY supervisor/nginx.conf /etc/supervisor/conf.d/

# Set default configuration.
RUN set -x \
    && cp /opt/graphite/webapp/graphite/local_settings.py.example /opt/graphite/webapp/graphite/local_settings.py \
    && cp /opt/graphite/conf/carbon.conf.example /opt/graphite/conf/carbon.conf \
    && cp /opt/graphite/conf/storage-schemas.conf.example /opt/graphite/conf/storage-schemas.conf \
    && cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/webapp/graphite/graphite_wsgi.py \
    # Create initial database.
    && PYTHONPATH=/opt/graphite/webapp django-admin.py migrate --settings=graphite.settings --run-syncdb \
    # Create static content.
    && PYTHONPATH=/opt/graphite/webapp django-admin.py collectstatic --noinput --settings=graphite.settings \
    # Set permissions.
    && chown -R www-data /opt/graphite/storage \
    # Remove Nginx default configuration.
    && rm /etc/nginx/sites-enabled/default \
    # Make sure entrypoint script is executable.
    && chmod +x /usr/local/bin/docker-entrypoint.sh

# Setup Nginx configuration.
COPY nginx/nginx.conf /etc/nginx/
COPY nginx/graphite.conf /etc/nginx/sites-enabled/
