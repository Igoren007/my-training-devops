# Потоковая репликация
## Настройка потоковой репликации

Поскольку в нашей конфигурации не будет архива журнала предзаписи, важно на всех этапах использовать слот репликации — иначе при определенной задержке мастер может успеть удалить
необходимые сегменты и весь процесс придется повторять с самого начала.

Создаем слот:
```bash
SELECT pg_create_physical_replication_slot('replica');
```

Посмотрим на созданный слот:
```bash
SELECT * FROM pg_replication_slots \gx
```
Создадим автономную резервную копию, используя созданный слот. С ключом -R утилита создает файлы, необходимые для будущей реплики.
```bash
$ pg_basebackup --pgdata=/home/student/backup -R --slot=replica
```

Файл postgresql.auto.conf был подготовлен утилитой pg\_basebackup, поскольку мы указали ключ -R. Он содержит информацию для подключения к мастеру (primary_conninfo) и имя слота
репликации (primary\_slot_name):
```bash
student$ cat /home/student/backup/postgresql.auto.conf
```

```bash
# Do not edit this file manually!
# It will be overwritten by the ALTER SYSTEM command.
primary_conninfo = 'user=student passfile=''/home/student/.pgpass'' channel_binding=prefer host=''/var/run/postgresql'' port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=
primary_slot_name = 'replica'
```
Тут также должен быть параметр **host** с адресом мастера.

Утилита также создала сигнальный файл **standby.signal**, наличие которого указывает серверу войти в режим постоянного восстановления.

Выкладываем резервную копию в каталог данных сервера beta.
```bash
$ sudo pg_ctlcluster 13 beta status
Error: /var/lib/postgresql/13/beta is not accessible or does not exist
$ sudo rm -rf /var/lib/postgresql/13/beta
$ sudo mv /home/student/backup /var/lib/postgresql/13/beta
$ sudo chown -R postgres:postgres /var/lib/postgresql/13/beta
```

## Процессы реплики
Посмотрим на процессы реплики.
```bash
$ ps -o pid,command --ppid `sudo head -n 1 /var/lib/postgresql/13/beta/postmaster.pid`
```

```bash
PID COMMAND
55897 postgres: 13/beta: startup recovering 000000010000000000000005
55898 postgres: 13/beta: checkpointer
55899 postgres: 13/beta: background writer
55900 postgres: 13/beta: stats collector
55901 postgres: 13/beta: walreceiver streaming 0/5000060
```

Процесс **wal receiver** принимает поток журнальных записей, процесс **startup** применяет изменения.
Процессы **wal writer** и **autovacuum launcher** отсутствуют.

И сравним с процессами мастера.
```bash
$ ps -o pid,command --ppid `sudo head -n 1 /var/lib/postgresql/13/alpha/postmaster.pid`
PID COMMAND
55450 postgres: 13/alpha: checkpointer
55451 postgres: 13/alpha: background writer
55452 postgres: 13/alpha: walwriter
55453 postgres: 13/alpha: autovacuum launcher
55454 postgres: 13/alpha: stats collector
55455 postgres: 13/alpha: logical replication launcher
55490 postgres: 13/alpha: student student [local] idle
55902 postgres: 13/alpha: walsender student [local] streaming 0/5000060
```

Здесь добавился процесс **wal sender**, обслуживающий подключение по протоколу репликации.

Состояние на слейве:

```bash
postgres@slave:~$ psql -c "\x" -c "SELECT * FROM pg_stat_wal_receiver;"

  Expanded display is on.
  -[ RECORD 1 ]---------+-------------
  pid                   | 5914
  status                | streaming
  receive_start_lsn     | 0/3000000
  receive_start_tli     | 1
  received_lsn          | 0/3000A00
  received_tli          | 1
  last_msg_send_time    | 2020-05-31 02:43:08.441605+00
  last_msg_receipt_time | 2020-05-31 02:43:08.472888+00
  latest_end_lsn        | 0/3000A00
  latest_end_time       | 2020-05-31 01:56:33.422365+00
  slot_name             | pgstandby1
  sender_host           | 192.168.33.33
  sender_port           | 5432
```

Состояние на мастере:
```bash
postgres@master:~$ psql -c "\x" -c "SELECT * FROM pg_stat_replication;"

Expanded display is on.
  -[ RECORD 1 ]----+------------------------------
  pid              | 6139
  usesysid         | 16384
  usename          | replicator
  application_name | 12/main
  client_addr      | 192.168.33.44
  client_hostname  |
  client_port      | 54930
  backend_start    | 2020-05-31 01:49:30.689483+00
  backend_xmin     |
  state            | streaming
  sent_lsn         | 0/3000A00
  write_lsn        | 0/3000A00
  flush_lsn        | 0/3000A00
  replay_lsn       | 0/3000A00
  write_lag        |
  flush_lag        |
  replay_lag       |
  sync_priority    | 1
  sync_state       | sync
  reply_time       | 2020-05-31 02:44:18.59281+00
```