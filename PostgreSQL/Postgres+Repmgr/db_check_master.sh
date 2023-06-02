#!/bin/bash
#в node_name = 'db2' указать нужное имя ноды

state=$(psql -p "$PG_PORT" -U postgres -d repmgr -At -c "select count(*) from repmgr.nodes where node_name = 'db2' and type='primary' and active = 'true';")
if [ "$state" = 1 ]; then
   exit 0
else
   exit 1
fi