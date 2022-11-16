Устанавдивается python3 на голый образ Linux Alpine.

Создать image:
```bash
docker build -t my_app .
```

Запустить контейнер:
```bash
 sudo docker run --rm --name -d my_app1 my_app
```

Создание volume data_output_txt, куда будут записываться данные из контейнера:
```bash
docker volume create data_output_txt
```


Запустить контейнер c volume:
```bash
 docker run --rm --name my_app_3 -d -v data_output_txt:/usr/src/data/ my_app
```

Просмотр содержимого volume:
```bash
sudo cat /var/lib/docker/volumes/data_output_txt/_data/output.txt
```
