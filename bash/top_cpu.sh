#!/bin/bash
#Топ 10 процессов по потреблению CPU (в выводе необходимо видеть cmd процесса, PID и проценты потребления CPU)
IFS=$'\n'
cpu_info=$(top -o %CPU | head -n 17 | tail -10)
for i in $cpu_info
do
  line=$(echo $i | awk '{print $2} {print $10} {print $13}')
  echo $line
done