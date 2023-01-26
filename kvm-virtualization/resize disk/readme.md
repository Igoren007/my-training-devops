**Узнать список дисков вм**
```bash
sudo virsh domblklist ub-srv3
```
```bash
 Target   Source
----------------------------------
 vda      /vz/disk/ub2-clone.img
 sda -
```

 **Определяем размер диска:**
```bash
$ sudo virsh domblkinfo ub-srv3 /vz/disk/ub2-clone.img
```
 
```bash
Capacity:       16106127360
Allocation:     8496320512
Physical:       8495497216
```
**Передаем изменения внутрь ВМ**
```bash
$ sudo virsh blockresize ub-srv3 /vz/disk/ub2-clone.img 18G
Block device '/vz/disk/ub2-clone.img' is resized
```


**после этого внутри вм**
```bash
$ lsblk
....................
vda                       252:0    0   18G  0 disk 
├─vda1                    252:1    0    1M  0 part 
├─vda2                    252:2    0  1.8G  0 part /boot
└─vda3                    252:3    0 13.3G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0   13G  0 lvm  /
```

 **Изменяем размер vda3**
```bash
$ sudo parted /dev/vda
..................................
GNU Parted 3.3
Using /dev/vda
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) print free                                                       
Warning: Not all of the space available to /dev/vda appears to be used, you can fix the GPT to use all of the space (an
extra 6291456 blocks) or continue with the current setting? 
Fix/Ignore? Fix                                                           
Model: Virtio Block Device (virtblk)
Disk /dev/vda: 19.3GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
Number  Start   End     Size    File system  Name  Flags
        17.4kB  1049kB  1031kB  Free Space
 1      1049kB  2097kB  1049kB                     bios_grub
 2      2097kB  1881MB  1879MB  ext4
 3      1881MB  16.1GB  14.2GB
        16.1GB  19.3GB  3222MB  Free Space
(parted) resizepart 3                                                    
End?  [16.1GB]? 19.3GB                                                    
(parted) print free                                                     
Model: Virtio Block Device (virtblk)
Disk /dev/vda: 19.3GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
Number  Start   End     Size    File system  Name  Flags
        17.4kB  1049kB  1031kB  Free Space
 1      1049kB  2097kB  1049kB                     bios_grub
 2      2097kB  1881MB  1879MB  ext4
 3      1881MB  19.3GB  17.4GB
        19.3GB  19.3GB  27.3MB  Free Space
```

**Увеличиваем  Phisical Volume**
```bash
$ sudo pvresize /dev/vda3
...................................
  Physical volume "/dev/vda3" changed
  1 physical volume(s) resized or updated / 0 physical volume(s) not resized
```

**Видим доступное место:**
```bash
$ sudo pvs
..............................
  PV         VG        Fmt  Attr PSize   PFree 
  /dev/vda3  ubuntu-vg lvm2 a--  <16.22g <3.22g
```

**Увеличиваем логический том**
```bash
$ sudo lvextend -L +3G /dev/ubuntu-vg/ubuntu-lv
.................................
  Size of logical volume ubuntu-vg/ubuntu-lv changed from 13.00 GiB (3328 extents) to 16.00 GiB (4096 extents).
  Logical volume ubuntu-vg/ubuntu-lv successfully resized.
```

**Увеличиваем файловую систему**
```bash
$ sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
......................................
resize2fs 1.45.5 (07-Jan-2020)
Filesystem at /dev/mapper/ubuntu--vg-ubuntu--lv is mounted on /; on-line resizing required
old_desc_blocks = 2, new_desc_blocks = 2
The filesystem on /dev/mapper/ubuntu--vg-ubuntu--lv is now 4194304 (4k) blocks long.
```
