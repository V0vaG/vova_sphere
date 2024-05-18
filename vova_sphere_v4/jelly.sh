#!/bin/bash
 
version='1.0.0'

if [[ $1 == '-v' ]]; then
	echo $version
	exit
elif [[ $1 == '-h' ]]; then
	echo "help"
	exit
fi
 
status(){
        sudo service jellyfin status
}
 
restart(){
        sudo systemctl restart jellyfin
}
 
start(){
        sudo systemctl start jellyfin
}
 
stop(){
        sudo systemctl stop jellyfin
}
 
main(){
    clear
    echo "Welcome to Vova's jellyfin_controller"
        func_list=(
        'exit'
        'status'
        'start'
        'stop'
        'restart'
        )
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
        echo " "
        read -p "Enter your choice (0-to go back): " ans
        clear
    ${func_list["$ans"]}
 
    main
}

main
