# monitoring-service

Здесь с помощью docker-compose запускается 2 сервиса: сайт на Django и БД PostgreSQL.

Образ Django создается через соответствующий Dockerfile.

Для PostgreSQL используется образ с dockerhub.
Данные хранятся в volume postgres_data. Имя базы, пользователь и пароль задаются переменными окружения:
```bash
- POSTGRES_DB=postgres
- POSTGRES_USER=postgres
- POSTGRES_PASSWORD=postgres
```

Некоторые переменные нужны для сервиса web, они задаются в файле .env.dev и используются для конфигурации БД в настройках Django:
```bash
DB_PORT=5432
DB_HOST=db
DB_PASSWORD=postgres
DB_USER=postgres
DB_DATABASE=postgres
DB_ENGINE=django.db.backends.postgresql
```

Запустить сервисы командой:
```bash
docker-compose up -d
```

Запустить миграции в БД:
```bash
docker-compose exec web python manage.py migrate --noinput
```

Убедиться что в БД были созданы нудные таблицы:
```bash
docker-compose exec db psql --username=postgres --dbname=postgres

psql (14.5 (Debian 14.5-1.pgdg110+1))
Type "help" for help.

postgres-# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```

Проверить что волюм был создан:
```bash
docker volume inspect monitoring-service_postgres_data
```