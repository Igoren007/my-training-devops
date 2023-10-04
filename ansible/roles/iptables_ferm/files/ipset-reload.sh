#!/bin/sh

IPSET_RULES=/etc/ipset.tables
TMP_IPSET_RULES=/tmp/ipset.tables.tmp

reload() {
    set -e
    setlist=$(awk '/^create / && $2 !~ /_tmp/ {print $2}' $IPSET_RULES)
    ipset -exist restore < $IPSET_RULES
    for list in $setlist; do
        ipset swap ${list}_tmp $list
        ipset destroy ${list}_tmp
    done
}

main() {
    reload
    [ $? -eq 0 ] && cp $IPSET_RULES $TMP_IPSET_RULES
}


if [ "$1" = '--force-reload' ];then
  rm $TMP_IPSET_RULES
fi

if [ ! -f $TMP_IPSET_RULES  ]; then
    main
else
    diff $IPSET_RULES $TMP_IPSET_RULES > /dev/null
    if [ $? -eq 1 ]; then
        main
    fi
fi
