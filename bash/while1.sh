task_name=$1

mkdir $task_name

starbase-mv $task_name

starbase-reactor-enable $task_name
starbase-charging $task_name
starbase-system-checking $task_name
starbase-engine-start $task_name
starbase-countdown  $task_name

current_status=$(starbase-status  $task_name)

echo "The status of launch is $current_status"

while [ $current_status="launching"]
if
    sleep 1
    current_status=$(starbase-status  $task_name)
fi

if  [  $current_status  =  "failed"  ]
then
    starbase-debug  $task_name
fi