#!/bin/bash
 
version='1.0.0'
 
if [[ $1 == '-v' ]]; then
	echo $version
	exit
elif [[ $1 == '-h' ]]; then
	echo "help"
	exit
fi
 
file_test='FAIL'
user_file_M="/home/$USER/my_scripts/ssh2/user_f"
conf_file="/home/$USER/my_scripts/ssh2/conf"
 
if [[ ! -f $conf_file ]]; then
	echo "Creating conf file..."
	sleep 2
sudo cat << EOF1 > $conf_file
file_test='OK'                
 
user_list=(
'vova'
'ubuntu'
'ec2-user'
)
 
declare -rA hosts=(
["raspnerry_pi"]="10.100.4.2"
["asus"]="10.100.4.3"
["server_local"]="10.100.102.1"
["server_remote"]="1.2.3.4"
)
 
EOF1
  
fi
source $conf_file
echo "Import config file... $file_test"
sleep 2
 
select_host(){
    clear
    echo "User: $user_name"
    i=0
    for host in "${!hosts[@]}"
    do
      ((i++))
      echo "$i. ${host}"
      tmp_array["$i"]="${host}"
    done
    echo "c. Costume ip"
    echo "0. Back"
    read -p "Enter 1-${#hosts[@]}, c or 0: " ans
    if [[ $ans == 0 ]]; then
        main
    elif [[ $ans == 'c' ]]; then
        read -p "Enter custom ip: " ans
        if [[ $ans == *'.'*'.'*'.'* ]]; then
            host_ip=$ans
        else
            echo "invalid input"
            sleep 3
            main
        fi
    elif (( $ans < ${#hosts[@]} || $ans > 0 )); then
        host_name=${tmp_array["$ans"]}
        host_ip=${hosts["$host_name"]}
    else
        echo "invalid input"
    fi
}
 
scp(){
	clear
    declare -A find_result_list
    declare -A result_dict
    echo "User: $user_name"
	select_host
	read -p "Enter file-name to send: " file
	if [[ $file == 0 ]]; then main; fi
	find_result_list=$(sudo find /home -name $file*)
    i=0
    for result_file in ${find_result_list}; do
        ((i++))
        result_dict["$i"]="${result_file}"
    done
	if [[ $i -gt 0 ]]; then
	    show_resolt(){
            i=0
            for result_file in ${find_result_list}; do
                if [[ -d $result_file ]]; then
            		type='DIR'
            	elif [[ -f $result_file ]]; then
            		type='FILE'
            	fi
                ((i++))
                echo "$i. $result_file ($type)"
            done
            read -p "Found $i files, which do u like 1-$i, 0-to go Back)? " ans
            if [[ $ans == 0 ]]; then
                main
            elif [[ $ans -gt $i || $ans -lt 0 ]]; then
                echo "Wrong choice!!!!! (0-$i)"
                sleep 3
                clear
                show_resolt
            fi
        }
        show_resolt
        if [[ -f ${result_dict["$ans"]} ]]; then
            echo "Sending file..."
            sudo scp ${result_dict["$ans"]} $user_name@$host_ip:~/.
        elif [[ -d ${result_dict["$ans"]} ]]; then
            echo "Sending dir...x"
	        sudo scp -r ${result_dict["$ans"]} $user_name@$host_ip:~/.
	    fi
	elif [[ $i -lt 1 ]]; then
		echo "The file was not found..."
		sleep 3
	fi
}
 
ssh(){
	clear
    declare -A tmp_array
    echo "hosts num: ${#hosts[@]}"
    echo "User $path_file"
	echo "Chose a host:"
    select_host
    sudo ssh $user_name@$host_ip
    sleep 10
    ssh
}
 
cmd(){
	clear
    select_host
    read -p "Enter a command: " user_cmd
    if [[ $user_cmd == 0 ]]; then
        main
    fi
    sudo ssh $user_name@$host_ip $user_cmd
}
 
change_user(){
    clear
    echo "Curent user: $user_file_M"
    i=0
    echo "Enter 1-${#user_list[@]} to select User, 0-to go Back or type *temp* user name: "
    for user in "${user_list[@]}"; do
        ((i++))
        echo "$i. $user"
    done
    read ans
    if [[ $ans == 0 ]]; then
        main
    elif [[ $ans > $i || $ans -lt 0 ]]; then
        user_list+=("$ans")
        change_user
    fi
    echo "Switching to user: ${user_list["(( $ans -1 ))"]}.."
    sleep 1
    user_name=${user_list["(( $ans -1 ))"]}
    echo "$(( $ans -1 ))" > $user_file_M
    main
}
 
options(){
    clear
    echo "***options***"
    echo "1. Change User Name"
    read -p "What to do: " ans
    clear
    option_list=(
    'main'
    'change_user'
    )
    ${option_list["$ans"]}
    main
}
 
main(){
    clear
    user_num=$(cat $user_file_M)
    if [[ ! $user_num < ${#user_list[@]}  ]]; then
        user_num=0
    fi
    user_name=${user_list["$user_num"]}
	echo "Welcome my friend, Welcome to the Machine"
	echo "User: $user_name"
	echo " "
	echo "1. SSH"
	echo "2. SCP"
	echo "3. CMD"
	echo "4. Options"
	echo "0. Exit"
	echo " "
	read -p "Enter your choice: " ans
	menu_list=(
	'exit'
	'ssh'
	'scp'
	'cmd'
	'options'
	)
	${menu_list["$ans"]}
	main
}
 
if [ ! -f $user_file_M ]; then
	 echo "0" > $user_file_M
fi

main

