#!/bin/bash
echo "Starting PostgreSQL ${PG_VERSION}..."
sleep 3
#echo "---ls /var/lib/postgresql/13/main---"
#ls -lah /var/lib/postgresql/13/main
#exec start-stop-daemon --start --chuid "${PG_USER}:${PG_USER}" \
#    --exec "${PG_BINDIR}/postgres" -- -D "${PG_DATADIR}"
#echo "\n----ls /etc/postgresql/${PG_VERSION}/main---"
ls -lah /var/lib/postgresql
ls -lah /etc/postgresql/${PG_VERSION}/main
ls -lah /etc/postgresql
#cat /etc/postgresql/${PG_VERSION}/main/postgresql.conf
#pg_ctlcluster 13 main start