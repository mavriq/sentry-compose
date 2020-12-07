#
ARG IMAGE_SENTRY_VERSION
FROM sentry:${IMAGE_SENTRY_VERSION}

ENV TERM=xterm \
    LANG=en_US.UTF-8 \
    LESS="-R -M -i --shift=1" \
    LESSCOLOR=always \
    force_color_prompt=yes

ARG VER_PG=9.6
ARG APT_GET="apt-get -y -q --no-install-recommends"
ENV PYTHONUNBUFFERED 1

RUN set -x \
    && $APT_GET update \
    && $APT_GET install \
        apt-transport-https \
        ca-certificates \
        gnupg2 \
        wget \
    && . /etc/os-release \
    && if [ -n "${VERSION_CODENAME+x}" ]; then \
        RELEASE="${VERSION_CODENAME}" ; \
    else \
        RELEASE=$(sed -nre 's;VERSION=.*\(([a-z]+)\).*;\1;p' < /etc/os-release) ; \
    fi \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" \
        | tee /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | apt-key add - \
    && $APT_GET update \
    && $APT_GET install \
        less \
        locales \
        redis-tools \
        pgbouncer postgresql-client-${VER_PG} \
    && pip install \
        ipython \
#        'raven<6.0.0,>=5.29.0' \
#        'redis>=2.10.6' \
        sentry-telegram \
\
    && echo "import sentry.conf.server" | tee -a /etc/sentry/sentry.conf.py \
    && echo "sentry.conf.server.LOGGING['loggers']['sentry.plugins.sentry_telegram'] = {'handlers': ['console'], 'level': 'DEBUG'}" | tee -a /etc/sentry/sentry.conf.py \
#    && pip check \
    && :
