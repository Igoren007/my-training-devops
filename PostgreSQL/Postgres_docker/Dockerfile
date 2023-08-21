FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV PG_VERSION=13 \
    PG_HOME=/var/lib/postgresql \
    PG_USER=postgres
    #PG_RUNDIR=/run/postgresql \
ENV PG_DATADIR=${PG_HOME}/${PG_VERSION}/main \
    PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin
    

RUN apt-get update &&\
        apt-get install -y --no-install-recommends gnupg wget lsb-core apt-transport-https ca-certificates
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -f -y --no-install-recommends \
        postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
    && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
    && locale-gen en_US.UTF-8 \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && ln -sf /etc/postgresql/${PG_VERSION}/main/postgresql.conf ${PG_DATADIR}/postgresql.conf\
    && ln -sf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf ${PG_DATADIR}/pg_hba.conf\
    && ln -sf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf ${PG_DATADIR}/pg_ident.conf \
    && ln -sf /etc/postgresql/${PG_VERSION}/main/conf.d ${PG_DATADIR}/conf.d

WORKDIR ${PG_HOME}
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh
CMD ["/sbin/entrypoint.sh"]