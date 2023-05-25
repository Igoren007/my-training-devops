Настраиваем кластер постгреса с потоковой репоикацией

PostgreSQL & Repmgr
Версия 12 для примера

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql-12


sudo apt install postgresql-12-repmgr
sudo apt install repmgr


В файл postgresql.conf добавляем:
listen_addresses = '*'
Это в режиме теста. Нужно указывать точные адреса.

Создание пользователя и базы данных с именем repmgr на primary узле:

createuser --superuser repmgr
createdb --owner=repmgr repmgr
psql -c "ALTER USER repmgr SET search_path TO repmgr, public;"

Добавим следующую строку в файл postgresql.conf:
Этот параметр загрузит библиотеки repmgr при запуске PostgreSQL. По умолчанию любые конфигурационные файлы PostgreSQL, присутствующие в каталоге data, будут скопированы на standby узлы.

shared_preload_libraries = 'repmgr'

Создаем файл с конфигурацией /etc/repmgr.conf

node_id=1
node_name='PG-Node1'
conninfo='host=192.168.122.132 user=repmgr dbname=repmgr 
connect_timeout=2'
data_directory='/var/lib/pgsql/12/data'


Далее добавим следующие строки в файл pg_hba.conf, он с primary узла будет скопирован на два standby узла
local   replication     repmgr                         trust
host    replication     repmgr      127.0.0.1/32       trust
host    replication     repmgr      172.31.16.0/20   trust

local   repmgr          repmgr                         trust
host    repmgr          repmgr      127.0.0.1/32       trust
host    repmgr          repmgr      172.31.16.0/20   trust

192.168.122.0/24 - как пример.

После этого нужно рестартонуть postgres

Под пользователем postgres запустим команду. Этим мы зарегистрируем инстанс PostgreSQL как primary с помощью repmgr. Эта команда так же  установит расширение repmgr и добавит метаданные о primary узле в базу данных repmgr.

/usr/bin/repmgr -f  /etc/repmgr.conf primary register


Теперь мы можем проверить состояние нашего кластера:

/usr/bin/repmgr -f /etc/repmgr.conf cluster show

Клонирование standby узлов

Выполним следующую команду на обоих standby узлах (PG-Node2 и PG-Node3) под пользователем postgres в режиме dry-run, чтобы убедиться, что всё сделали правильно  перед фактическим клонированием данных с primary узла:

/usr/bin/repmgr -h 172.31.27.51 -U repmgr -d repmgr -f /etc/repmgr.conf standby clone --dry-run


Если вывод похож на следующий, значит клонирование было успешным:

NOTICE: using provided configuration file "/etc/repmgr.conf"
destination directory "/var/lib/pgsql/12/data" provided
INFO: connecting to source node
NOTICE: checking for available walsenders on source node (2 required)
INFO: sufficient walsenders available on source node (2 required)
NOTICE: standby will attach to upstream node 1
HINT: consider using the -c/--fast-checkpoint option
INFO: all prerequisites for "standby clone" are met


/usr/bin/repmgr -h 172.31.27.51 -U repmgr -d repmgr -f /etc/repmgr.conf standby clone

В случае успеха увидим:

NOTICE: standby clone (using pg_basebackup) complete
NOTICE: you can now start your PostgreSQL server
HINT: for example: pg_ctl -D /var/lib/pgsql/12/data start
HINT: after starting the server, you need to register this standby with "repmgr standby register"


На этом этапе PostgreSQL не работает ни на одном из standby узлов, хотя у обоих есть каталог данных Postgres, скопированный с primary (включая любые файлы конфигурации PostgreSQL, присутствующие в каталоге данных primary узла). Мы запускаем и включаем postgresql на обоих узлах:

 systemctl start postgresql.service
 systemctl enable postgresql.service

 Затем мы запускаем следующую команду на каждом standby узле под пользователем postgres, чтобы зарегистрировать его в repmgr:

/usr/bin/repmgr -f /etc/repmgr.conf standby register

Проверим статус:

/usr/bin/repmgr -f  /etc/repmgr.conf cluster show --compact


Настройка кластера на автоматизацию отказоустойчивости

Когда кластер работает, мы добавляем следующие строки в файл /etc/sudoers в каждом узле кластера и узле-свидетеля:

Defaults:postgres !requiretty
postgres ALL = NOPASSWD: sudo systemctl stop postgresql.service, sudo systemctl start postgresql.service, sudo systemctl restart postgresql.service, sudo systemctl reload postgresql.service, sudo systemctl start repmgrd.service, sudo systemctl stop repmgrd.service

или так
postgres ALL=(ALL) NOPASSWD:ALL

Настройка параметров repmgrd

Параметр отработки отказа является одним из обязательных параметров для демона repmgr. Этот параметр сообщает демону, следует ли ему инициировать автоматическое аварийное переключение при обнаружении ситуации аварийного переключения. Может иметь одно из двух значений: "manual" или "automatic"

failover='automatic'


promote_command
Еще один обязательный параметр для демона repmgr. Этот параметр сообщает демону repmgr, какую команду он должен выполнить, чтобы активировать резервный узел.
promote_command='/usr/bin/repmgr standby promote -f /etc/repmgr.conf'

follow_command
Третий обязательный параметр для демона repmgr. Этот параметр указывает резервному узлу следовать за новым primary.

follow_command='/usr/bin/repmgr standby follow -f /etc/repmgr.conf'

priority
Параметр priority добавляет вес к праву узла стать основным.

monitor_interval_secs
Параметр сообщает демону repmgr, как часто (в секундах) он должен проверять доступность вышестоящего узла. В нашем случае существует только один вышестоящий узел: основной узел. Значение по умолчанию составляет 2 секунды, но мы явно устанавливим это значение на каждом узле:
monitor_interval_secs = 2


connection_check_type
connection_check_type указывает, какой протокол будет использоваться для связи с вышестоящим узлом. Этот параметр может принимать три значения:
ping: repmgr использует метод PQPing().
connection: repmgr пытается создать новое соединение с вышестоящим узлом.
query: repmgr пытается выполнить SQL-запрос на вышестоящем узле, используя существующее соединение.

connection_check_type = 'ping'


reconnect_attempts и reconnect_interval
Когда первичный сервер становится недоступным, демон repmgr на резервных узлах будет пытаться переподключиться к первичному серверу reconnect_attempts раз. Значение по умолчанию для этого параметра - 2. Между каждой попыткой переподключения он будет ждать reconnect_interval секунд, значение по умолчанию которого равно 2.


reconnect_attempts=2
reconnect_interval=2


primary_visibility_consensus
Когда первичный сервер становится недоступным в многоузловом кластере, резервные узлы могут консультироваться друг с другом, чтобы создать кворум для отработки отказа, спрашивая каждый резервный узел о времени, когда он в последний раз видел основной узел. Если последняя связь с узлом была недавней и позже времени, когда этот узел увидел первичный узел, локальный узел предполагает, что первичный узел все еще доступен, и не принимает решение об отказоустойчивости.

primary_visibility_consensus = true


standby_disconnect_on_failover
Когда для параметра standby_disconnect_on_failover на резервном узле задано значение "true", демон repmgr будет гарантировать, что его приемник WAL отключен от основного и не получает сегменты WAL. Он также будет ждать, пока приемники WAL других резервных узлов прекратят работу, прежде чем принимать решение об отказоустойчивости.

Для этого параметра должно быть установлено одинаковое значение на каждом узле. true означает, что каждый резервный узел прекратил получать данные с первичного сервера при сбое.
standby_disconnect_on_failover = true


repmgrd_service_start_command и repmgrd_service_stop_command
Эти два параметра определяют, как запускать и останавливать демон repmgr с помощью команд "repmgr daemon start" и "repmgr daemon stop".


repmgrd_service_start_command='sudo systemctl start repmgrd.service'
repmgrd_service_stop_command='sudo systemctl stop repmgrd.service'


Команды Start/Stop/Restart службы PostgreSQL
В рамках своей работы демон repmgr часто должен останавливать, запускать или перезапускать службу PostgreSQL. Чтобы это происходило гладко, лучше всего указать соответствующие команды операционной системы в качестве значений параметров в файле repmgr.conf. Для этого на каждом узле установим четыре параметра:

service_start_command='sudo systemctl start postgresql.service'
service_stop_command='sudo systemctl stop postgresql.service'
service_restart_command='sudo systemctl restart postgresql.service'
service_reload_command='sudo systemctl reload postgresql.service'


monitoring_history
Если для параметра monitor_history задано значение "yes", repmgr сохраняет свои данные мониторинга кластера.

Установим "yes" на каждом узле:
monitoring_history=yes


log_status_interval
Мы устанавливаем параметр на каждом узле, чтобы указать, как часто демон repmgr будет регистрировать сообщение о состоянии.

log_status_interval=60

Итого должно получиться примерно так:

node_id=3
node_name='db3'
conninfo='host=172.31.29.241 user=repmgr dbname=repmgr connect_timeout=2'
data_directory='/var/lib/postgresql/12/main'
failover='automatic'
promote_command='/usr/bin/repmgr standby promote -f /etc/repmgr.conf'
follow_command='/usr/bin/repmgr standby follow -f /etc/repmgr.conf'
monitor_interval_secs = 2
connection_check_type = 'ping'
reconnect_attempts=2
reconnect_interval=2
use_replication_slots=1
primary_visibility_consensus = true
standby_disconnect_on_failover = true
repmgrd_service_start_command='sudo systemctl start repmgrd.service'
repmgrd_service_stop_command='sudo systemctl stop repmgrd.service'
service_start_command='sudo systemctl start postgresql.service'
service_stop_command='sudo systemctl stop postgresql.service'
service_restart_command='sudo systemctl restart postgresql.service'
service_reload_command='sudo systemctl reload postgresql.service'



Запуск демона repmgr
Теперь, когда параметры установлены в кластере и на узле-свидетеле, выполним пробный запуск команды, чтобы запустить демон repmgr. Сначала проверяем это на основном узле, а затем на двух резервных узлах, а затем на узле-свидетеле.

Команда должна быть выполнена от имени postgres:
/usr/bin/repmgr -f /etc/repmgr.conf daemon start --dry-run

Вывод должен быть таким:

INFO: prerequisites for starting repmgrd met
DETAIL: following command would be executed:
  sudo /usr/bin/systemctl start repmgr12.service


  Далее запускаем демон на всех узлах:

  /usr/bin/repmgr -f /etc/repmgr.conf daemon start

  Выходные данные в каждом узле должны показать, что демон запущен:
NOTICE: executing: "sudo /usr/bin/systemctl start repmgr12.service"
NOTICE: repmgrd was successfully started


Также проверим событие запуска службы с основного или резервного узлов:
/usr/bin/repmgr -f /etc/repmgr.conf cluster event --event=repmgrd_start