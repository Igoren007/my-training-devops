#!/bin/bash

# Destoy ipset and related iptables rules

SETNAME="$1"
TABLES="raw nat mangle filter"
CHAINS="INPUT OUTPUT FORWARD PREROUTING POSTROUTING"


if [ -z "$SETNAME" ];then
  echo "ERROR: set name required"
  exit 1
fi

if ! ipset list -n "$SETNAME" > /dev/null 2>&1; then
  echo "ipset [$SETNAME] not found"
  exit 0
fi

for table in $TABLES; do
  for chain in $CHAINS; do
    rulenums=$( iptables -t $table -L $chain --line-numbers 2> /dev/null | awk '/match-set '$SETNAME' /{print $1}' | sort -r -n )
    for rulenum in $rulenums; do
        echo "Deleting rule: [$rulenum] from table: [$table] containing ipset: [$SETNAME]"
        iptables -t $table -D $chain $rulenum
    done
  done
done

echo "Deleting ipset: [$SETNAME]"
ipset destroy $SETNAME
