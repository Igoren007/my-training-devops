docker-compose.yml - compose файл с описанием сервера прометея, графаны, алертменеджера и тд.

Запуск контейнеров для мониторинга параметров хоста и контенеров на этом хосте - worker_node.yml

rule_files - указываем файл, где описаны алерты (/prometheus/alert.rules)

alerting - указываем куда отправлять наши алерты("alertmanager:9093")

Дашборды для графаны:

https://grafana.com/grafana/dashboards/1860-node-exporter-full/
https://grafana.com/grafana/dashboards/14282-cadvisor-exporter/