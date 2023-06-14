start=$1
stop=$2
num=$1

while [ $num -le $stop ]
do
    if [ $(( $num % 2 )) -eq 0 ]
    then
        echo "launch-$num"
    fi
    num=$(( $num + 1))
done