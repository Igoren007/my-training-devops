# Docker Compose

Запустить:
```bash
sudo docker-compose up -d
```

Остановить:
```bash
sudo docker-compose stop
```

Продолжить работу:
```bash
sudo docker-compose start
```

Остановить и удалить неиспользуемые ресурсы(*контейнер, сеть*):
```bash
sudo docker-compose down
```

Запустить конкретный сервис:
```bash
sudo docker-compose run <service-name>
```

Запустить c использованием переменных окружения:
```bash
sudo docker-compose --env-file <path-to-file> up -d
```

Композиция docker-compose.yml, например, чтобы переопределить какие-то параметры:
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```