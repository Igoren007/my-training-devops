#! /bin/bash

echo "Hello from bash"

#--------------------------------

FIRTS_STRING="hi !"
e
#--------------------------------

echo "Enter your name:"
read NAME
echo $NAME
echo "Hello, $NAME"

#--------------------------------

echo "Enter your name & surname"
read NAME SURNAME
echo "Name: $NAME"
echo "SURNAME: $SURNAME"

#--------------------------------
# a - создать массив, p - не переносить ввод на следующую строку, s - скрыть вводимые символы

echo "Enter 3 strings:"
read -a STRINGS
echo "Strings: ${STRINGS[0]}, ${STRINGS[1]}, ${STRINGS[2]}"

#--------------------------------

