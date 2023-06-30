#!/bin/bash

vm=$(sudo virsh list --all | tail -n +3 | awk '{print $2}')
echo ${vm[@]}

for i in $vm
do
    CPU_i=$(sudo virsh dominfo $i | grep "CPU(s)"  | awk '{print $2}')
    Mem_i=$(sudo virsh dominfo $i | grep "Max mem" | awk '{print $3}')
    echo "$i: $CPU_i CPU $(expr $Mem_i / 1024) Mb"
done
