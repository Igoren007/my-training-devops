while true
do
echo "1. Add"
echo "2. Subtract"
echo "3. Multiply"
echo "4. Divide"
echo "5. Exit"

read choise
if [ $choise -eq 5 ]
then
    exit 
else
    read -p "num1:" num1
    read -p "num2:" num2
    if [ $choise -eq 1 ]
    then
        echo "Answer=$(( $num1 + $num2 ))"
    fi
    if [ $choise -eq 2 ]
    then
        echo "Answer=$(( $num1 - $num2 ))"
    fi
    if [ $choise -eq 3 ]
    then
        echo "Answer=$(( $num1 * $num2 ))"
    fi
    if [ $choise -eq 4 ]
    then
        echo "Answer=$(( $num1 / $num2 ))"
    fi
fi 
done