## Команды для работы с ВМ:

показать список запущенных ВМ
 ```bash
virsh list
```

показать список всех машин (в том числе выключенных)
 ```bash
virsh list --all
```

 выключить виртуальную машину
 ```bash
virsh shutdown <vm name>
```

запустить виртуальную машину

 ```bash
virsh start <vm name>
```

 приостановить виртуальную машину
 
 ```bash
virsh suspend <vm name>
```

запустить приостановленную виртуальную машину
 ```bash
virsh resume <vm name>
```

перезапустить виртуальную машину
 ```bash
virsh reboot <vm name>
```

уничтожить виртуальную машину
 ```bash
virsh destroy <vm name>
```

удалить машину из списка и удалить все файлы, принадлежащие ей (обычно применяется после выполнения команды virsh destroy)
```bash
virsh undefine <vm name>
```

## Информация о ВМ:

информация о процессоре на ВМ
```bash
virsh vcpuinfo <vm name>
```
получить идентификатор ВМ
```bash
virsh domid <vm name>
```

получить UUID ВМ
```bash
virsh domuuid <vm name>
```

получить сведения о ВМ
```bash
virsh dominfo <vm name>
```

просмотр состояния ВМ
```bash
virsh domstate <vm name>
```
вывести файл конфигурации ВМ в XML формате
```bash
virsh dumpxml <vm name>
```

Подсчет суммарного потребления по ядрам и памяти виртуалок на хосте
```bash
sudo virsh list | tail -n +3 |awk '{print $2}' | (C=0; M=0; while read NAME; do if [[ -n $NAME ]]; then CPU=$(sudo virsh dominfo $NAME|grep 'CPU(s)'|awk '{print $2}') ; MEM=$(sudo virsh dominfo $NAME | grep "Max mem"|awk '{print $3}'); ((MEM/=1024)); echo "$NAME $CPU $MEM"; ((C+=CPU)); ((M+=MEM)); fi; done; ((M/=1024)); echo "TOTAL $C $M GB")
```


## Изменение параметров ВМ

 Чтобы увеличить максимальное количество ядер ВМ, выполним команду:
```bash
virsh setvcpus <vm name> --config --maximum
```
Добавить ядер:
```bash
virsh setvcpus <vm_name> 6 --config
```
Если ВМ включена, то наживую добавлять без параметра `--config`.

Так же с памятью:
```bash
virsh setmem <vm_name> <memsize> --config --maximum
```
```bash
virsh setmaxmem <vm_name> 6G --config
```
Либо можно отредактировать XML файл ВМ в онлайн режиме
```bash
virsh edit <vm_name>
```

Тоже самое можно сделать, сделав бэкап XML файла:

```bash
virsh dumpxml <vm_name> > /root/test.xml
vi /root/test.xml
```

Измените нужные вам параметры, сохраните файл и примените к ВМ:

```bash
virsh shutdown <vm_name>

Domain <vm_name> is being shutdown

virsh define /root/test.xml

Domain test-centos defined from /root/test.xml

virsh start <vm_name>
```

## Закрепить IP за MACом для ВМ на DHCP-сервере гипервизора:

Смотрим и запоминаем IP и идём на хост машину. Вытаскиваем mac-адрес "сетевой" карты виртуалки:

```bash
virsh  dumpxml  <vm_name> | grep 'mac address'
```

Запоминаем наш mac адрес:

```bash
<mac address='52:54:00:84:e0:7b'/>
```

Редактируем сетевые настройки гипервизора:

```bash
sudo virsh net-edit default
```

Ищем DHCP, и добавляем вот это:

```bash
<host mac='52:54:00:84:e0:7b' name='ubuntu1604' ip='192.168.122.131'/>
```

Должно получиться что-то вроде этого:

```bash
<dhcp>
<range start='192.168.122.2' end='192.168.122.254'/>
<host mac='52:54:00:84:e0:7b' name='ubuntu1604' ip='192.168.122.131'/>
</dhcp>
```

Для того, чтобы настройки вступили в силу, необходимо перезагрузить DHCP сервер гипервизора:

```bash
sudo virsh net-destroy default
sudo virsh net-start default
sudo service libvirt-bin restart
```

## Добавление сетевой карты для ВМ

Сначала проверим, какие сетевые интерфейсы созданы на хосте:

```bash
brctl show
```

К br0 нам нужно прикрепить еще один виртуальный сетевой интерфейс. Выполните команды:

```bash
virsh shutdown <vm_name>
virsh attach-interface <vm_name> --type bridge --source br0 --persistent
virsh start <vm_name>
```

## Добавление диска в ВМ

Сначала нужно создать дополнительный файл диска для виртуальной машины:

```bash
qemu-img create -f qcow2 -o size=20G /vz/disk/test.img
```

После этого, можно добавить устройство виртуального диска к самой ВМ:

```bash
virsh attach-disk <vm_name> /vz/disk/test.img vdb --type disk --persistent
```

Остановите и запустите ВМ, проверьте что получилось:

```bash
virsh shutdown <vm_name>
```


Domain test-centos is being shutdown
```bash
virsh start <vm_name>
```

Domain test-centos started
```bash
virsh dumpxml <vm_name>
```

