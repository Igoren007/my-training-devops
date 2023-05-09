FROM postgres:13 

RUN apt-get update -y\ 
    && apt-get install -y iputils-ping procps \
    && apt-get install python3 python3-pip -y\
    && pip3 install --upgrade setuptools\
    && pip3 install psycopg2-binary \
    && pip3 install patroni[etcd] \
    && mkdir /db -p \
    && chown postgres:postgres /db \
    && chmod 700 /db 

COPY patroni.yml /etc/patroni/patroni.yml
COPY patroni_entrypoint.sh ./entrypoint.sh
USER postgres

ENTRYPOINT ["bin/sh", "/entrypoint.sh"]