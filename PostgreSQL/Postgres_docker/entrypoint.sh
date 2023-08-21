#!/bin/bash

echo "Starting PostgreSQL ${PG_VERSION}..."
start-stop-daemon --start --chuid "${PG_USER}:${PG_USER}" --exec "${PG_BINDIR}/postgres" -- -D "${PG_DATADIR}"