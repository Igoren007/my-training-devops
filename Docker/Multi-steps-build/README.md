# Пример многоэтапной сборки

- Сборка на golang:alpine
- Запуск на scratch из собранного bin

Сборка следующей командой:
```bash
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build
```

Собрать image:
```bash
docker build -t go-api:latest .
```

Запустить контейнер:
```bash
docker run -d --name go-api-1 go-api
```