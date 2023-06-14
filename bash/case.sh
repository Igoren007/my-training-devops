name=$1

case $name in
    Fedora | RHEL | CentOS )
    echo It is 'yum' command.
    ;;
    Debian | Ubuntu )
    echo It is 'apt' command.
    ;;
    Alpine )
    echo It is 'apk' command.
    ;;
    Arch )
    echo It is 'pacman' command.
    ;;
esac