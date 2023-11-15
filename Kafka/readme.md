/usr/bin/kafka-topics --create --topic test-topic --bootstrap-server localhost:29092

/usr/bin/kafka-topics --create --topic test-topic --bootstrap-server localhost:29092



/usr/bin/kafka-console-producer --broker-list localhost:29092 --topic logs



/usr/bin/kafka-console-consumer --bootstrap-server localhost:29092 --topic logs --from-beginning





Zookeper comands: https://zookeeper.apache.org/doc/r3.9.1/zookeeperCLI.html