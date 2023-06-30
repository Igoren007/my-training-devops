#!/bin/bash
#в node_name = 'db2' указать нужное имя ноды

state=$(curl -s http://localhost:8008/patroni | jq '.role' | tr -d \")
if [ "$state" = master ]; then
   exit 0
else
   exit 1
fi