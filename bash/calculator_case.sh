while true
do
  echo "1. Add"
  echo "2. Subsctract"
  echo "3. Multiply"
  echo "4. Divide"
  echo "5. Average"
  echo "6. Quit"

read choise
case $choise in
1) read -p "num1:" num1
   read -p "num2:" num2
   echo "Answer=$(( $num1 + $num2 ))"
   ;;
2) read -p "num1:" num1
   read -p "num2:" num2
   echo "Answer=$(( $num1 - $num2 ))"
   ;;
3) read -p "num1:" num1
   read -p "num2:" num2
   echo "Answer=$(( $num1 * $num2 ))"
   ;;
4) read -p "num1:" num1
   read -p "num2:" num2
   echo "Answer=$(( $num1 / $num2 ))"
   ;;
5) read -p "num1:" num1
   read -p "num2:" num2
   sum=$(( $num1 + $num2))
   echo "Answer=$(echo "$sum / 2" | bc -l)"
   ;;
6) exit
   ;;
esac
done