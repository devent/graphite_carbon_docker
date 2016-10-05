FROM debian:8.6

# Configuration variables.
ENV DEBIAN_FRONTEND noninteractive
ENV GRAPHITE_VERSION 0.9.15
ENV GUNICORN_VERSION 19.6.0

# Install tools and xmlstarlet to configure the Tomcat XML files.
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends \
        # python
        gcc \
        python-dev \
        libcairo2-dev \
        libffi-dev \
        python-pip \
        python-ldap \
        python-cairo \
        python-django \
        python-twisted \
        python-django-tagging \
        python-simplejson \
        python-memcache \
        python-pysqlite2 \
        python-tz \
        # postgresql
        libpq-dev python-psycopg2 \
        # supervisor
        supervisor \
        # nginx
        nginx-light \
    && rm -rf /var/lib/apt/lists/*

# Install whisper.
RUN set -x \
    && export PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/" \
    && pip install "https://github.com/graphite-project/whisper/archive/${GRAPHITE_VERSION}.tar.gz"

# Install carbon.
RUN set -x \
    && export PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/" \
    && pip install "https://github.com/graphite-project/carbon/archive/${GRAPHITE_VERSION}.tar.gz"

# Install graphine.
RUN set -x \
    && export PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/" \
    && pip install "https://github.com/graphite-project/graphite-web/archive/${GRAPHITE_VERSION}.tar.gz"

# Install gunicorn.
RUN set -x \
    && pip install gunicorn==$GUNICORN_VERSION

# Whisper storage directory.
VOLUME /var/lib/graphite/storage/whisper

# Carbon line receiver port.
EXPOSE 2003

# Carbon pickle receiver port.
EXPOSE 2004

# Carbon cache query port.
EXPOSE 7002

# Webapp HTTP port.
EXPOSE 8000

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

# Set default configuration.
RUN set -x \
    && cp /opt/graphite/webapp/graphite/local_settings.py.example /opt/graphite/webapp/graphite/local_settings.py \
    && cp /opt/graphite/conf/carbon.conf.example /opt/graphite/conf/carbon.conf \
    && cp /opt/graphite/conf/storage-schemas.conf.example /opt/graphite/conf/storage-schemas.conf \
    && cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/webapp/graphite/graphite_wsgi.py \
    # Create initial database.
    && cd /opt/graphite/webapp/graphite && python manage.py syncdb --noinput \
    # Copy graphite-web WSGI.
    && cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/webapp/graphite/graphite_wsgi.py \
    # Set permissions.
    && chown -R www-data /opt/graphite/storage \
    # Make sure entrypoint script is executable.
    && chmod +x /usr/local/bin/docker-entrypoint.sh
