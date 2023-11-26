# Работа с LVM

(Подробная статья: https://www.dmosk.ru/instruktions.php?object=lvm)

## Создаем PV, VG, LV 

Есть диск /dev/sdb. Создадаим на нем раздел:

```bash
fdisk /dev/sdb
```


Получили:

```bash
sdb                         8:16   0    3G  0 disk
└─sdb1                      8:17   0    1G  0 part
```


Создадим physical volume:

```bash
sudo pvcreate /dev/sdb1
........
  Physical volume "/dev/sdb1" successfully created.

sudo pvs
.......
/dev/sdb1            lvm2 ---    1.00g   1.00g
```


Создание группы томов (volume group):

```bash
sudo vgcreate vg-data /dev/sdb1

Volume group "vg-data" successfully created
```


Создание логических томов:

```bash
lvcreate -n lvdata -l 50%FREE vg-data
```


-l 50%FREE - 50% от vg-data. Можно, к примеру,  -L 1G 

Теперь можно создать файловую систему на логическом томе:

```bash
sudo mkfs.ext4 /dev/vg-data/lvdata
```


Создаем директорию /mnt/lvdata, добавляем запись в /etc/fstab для автомонтирования при запуске:

```bash
/dev/vg-data/lvdata /mnt/lvdata ext4 defaults 1 2
```


монтируем том:

```bash
mount /dev/vg-data/lvdata /mnt/lvdata/
```


получаем:

```bash
/dev/mapper/vg--data-lvdata        476M   24K  440M   1% /mnt/lvdata
```

Проверить статус логического тома:

```bash
lvscan
```


## Изменение размера

Если меняем размер существующего диска(например это диск для виртуалки), нужно увеличить размер физического диска командой:

```bash
sudo pvresize /dev/sdb
```


Добавление нового диска к группе томов

Создаем новый PV:

```bash
sudo pvcreate /dev/sdc1
```


Добавляем его в VG:

```bash
sudo vgextend vg-data /dev/sdc1

vg-data     2   1   0 wz--n-  2.99g  <2.50g
```


Расширяем логический раздел на 2 Гб:

```bash
sudo lvextend -L +2G /dev/vg-data/lvdata

lvdata    vg-data   -wi-ao----  <2.50g
```


Расширить файловую систему:
```bash
sudo resize2fs /dev/vg-data/lvdata
```



## Уменьшение томов

LVM также позволяет уменьшить размер тома. Для этого необходимо выполнить его отмонтирование.

```bash
sudo umount /mnt/lvdata
```

Проверяем:

```bash
sudo e2fsck -fy /dev/vg-data/lvdata
```


Уменьшаем размер файловой системы до 1 Гб:

```bash
sudo resize2fs /dev/vg-data/lvdata 1G
```


Уменьшаем размер тома до 1 Гб:

```bash
lvreduce -L 1G /dev/vg-data/lvdata
```



## Удаление томов

Отмонтируем:

```bash
sudo umount /mnt/lvdata
```


Удаляем логический том:

```bash
sudo lvremove /dev/vg-data/lvdata
```


Удаляем группу томов:
```bash
sudo vgremove vg-data
```



Удаляем физический том:

```bash
sudo pvremove /dev/sdc1
sudo pvremove /dev/sdb1
```


Перед удалением логический том нужно деактивировать:

```bash
sudo lvchange -an /dev/vg-data/lvdata
```
