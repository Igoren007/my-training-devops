register.py регистрирует хост в ZK при запуске и удаляет при остановке.
get_targets.py вычитывает хосты из ZK и отдает по http в виде json.

# connect to the localhost with the default port:2181
bin/zkCli.sh

# create a persistent_node
[zkshell: 7] create /persistent_node
	Created /persistent_node

[zkshell: 2] delete /config/topics/test

Get the data of the specific path

[zkshell: 10] get /latest_producer_id_block
