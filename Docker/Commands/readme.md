# Команды в контейнере

```bash
docker exec [params] [name] [command]
```
* **i** - интерасктивно
* **t** - псевдо tty
* **d** - запуск в фоне
* **e** - переменные окружения
* **u** - пользователь
* **w** - рабочая директория

## Примеры:

Путь к текущей директории в контейнере:
```bash
sudo docker exec -w /root my_app_3 pwd
```
Передать переменную окружения и увидеть  ее в списке:
```bash
sudo docker exec -e MYVAR=123 my_app_3 printenv
```
Bash внутри контейнера:
```bash
sudo docker exec -it my_app_3 bash
```
Команда внутри контейнера:
```bash
sudo docker exec my_app_3 bash -с "ls"
```
Удалить запущенный контейнер my_container:
```bash
docker rm my_container -f
```

Записать вывод команды в файл:
```bash
sudo docker exec my_app_3 uptime > text.txt
```

# Volumes


Список volums:
```bash
docker volume ls
```

Создать volume:
```bash
docker volume create v1
```
Volums хранятся по пути:
```bash
/var/lib/docker/volumes/
```

# Информация о контейнерах

Потребление ресурсов контейнером:
```bash
docker stats
```

Информация о контейнере:
```bash
docker inspect <name>
```

Просмотр конкретного параметра контейнера:
```bash
docker inspect -f "{{.State.Status}}" <name>
```

Просмотр логов:
```bash
docker logs <name>
```

# Сети

### Типы:
* *bridge*
* *host* - может быть только одна
* *none* - может быть только одна
* *macvlan* - каждый контейнер получает свой mac 
* *ipvlan* - контейнер имеет mac хоста

Посмотреть какие есть типы сети в докере:
```bash
docker network ls
```

Создать новую сеть и именем **NAME** и типом **bridge**. 

**--driver bridge** можно не указывать, тогда тип также будет **bridge**.
```bash
docker network create --driver bridge NAME
```
Чтобы контейнеры видели друг друга по имени, они должны быть запущены в одной сети.

Создать сеть со своим диапазоном адресов:
```bash
docker network create --driver bridge --subnet 192.168.10.0/24 --gateway 192.168.10.1 MyNet192
```

Запустить контейнер в этой сети:
```bash
docker run --net <NAME> image-name
```

Задать контейнеру IP:
```bash
docker run --net <NAME> --ip x.x.x.x image-name
```

Переместить работающий контейнер в определенную сеть:
```bash
docker network connect <Network-NAME> <container-name>
```

Отключить контейнер от сети:
```bash
docker network disconnect <Network-ID> <container-name>
```

Получить информацию о какой-то сети:
```bash
docker network inspect mynet1
```

Удалить сеть:
```bash
docker network rm mynet1
```

Задать DNS для контейнера:
```bash
docker run --net <NAME> --dns <dns-ip> image-name1
```


Cохранить image на диск:
```bash
docker save --output <archive-name.tar> <image name>
```