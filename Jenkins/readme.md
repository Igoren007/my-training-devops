## Install Jenkins master

Используем docker-compose-jenkins-master.yml

`~/jenkins_home:/var/jenkins_home` - рабочий каталог Jenkins


## Как подключить slave

На мастере генерируем ssh ключ:
```bash
ssh-keygen -t rsa -f jenkins_slave
```

Выполняем команду и копируем содержимое файла
```bash
cat jenkins_slave
```

Открываем web-интерфейс Jenkins, переходим в Manage Jenkins-> Manage Credentials и там указываем ключ.

Заходим на slave, ставим java:
```bash
apt install openjdk-11-jre-headless
```

Создаем пользователя **jenkins** и задаем для него пароль
```bash
sudo useradd -m -s /bin/bash jenkins
```

Настраиваем для него ssh подключение:
```bash
mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

В **authorized_keys** копируем публичный ключ.

Переходим в web интерфейс Jenkins - Manage Jenkins -> Manage Node and Cloud -> Нажимаем New Node, вводим произвольное имя агента, и ставим галочку Permanent Agent.
Заполняем поля, выбираем ранее созданный Credentials, сохраняем и нажимаем Relaunch agent.


