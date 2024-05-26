#!/bin/bash
  
version='1.3.6'

################################
# Author: Vladimir Glayzer     #
# eMail: its_a_vio@hotmail.com #
################################

file_test='FAIL'

conf_file="/home/$USER/my_scripts/pass/conf"
remote="no"

if [[ ! -f $conf_file ]]; then
	echo "Creating conf file..."
	sleep 2
cat << EOF1 > "$conf_file"
file_test='OK' 

user='usr'
host_ip='1.2.3.4a'

local_temp_file="/tmp/temp.tmp"
remote_temp_file="/tmp/temp2.tmp"

remote_file_list=(
"/home/$USER/..." # remote file 1
"/home/$USER/..." # remote file 2
)

local_file_list=(
"/home/$USER/..." # local file 1
"/home/$USER/..." # local file 2
)

EOF1
fi

source "$conf_file"
echo "Import config file... $file_test"
sleep 0.5

remote_host="$user@$host_ip"

security_check(){
    if [[ -f "$1" ]]; then
        echo "$1 was not deleted!!!!!!!!!!"
        read -p "To delete the file (y/n)? " ans
	    if [[ $ans == 'y' ]]; then
    	    rm "$1"
        fi
    fi
}

security_check "$local_temp_file"
security_check "$remote_temp_file"

ip_check(){
    if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "IP OK"
    else
      echo "ERROR IP fail"
      sleep 1
      exit
    fi
}

if [[ -f "$local_temp_file" ]]; then
	echo "$local_temp_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm "$local_temp_file"
    	exit
    fi
    exit
fi
 
help(){
echo "pass (Password manager)
############################
# Author: Vladimir Glayzer #
############################

Version: $version        

This Script manages secrets locally & remotely via SSH.

0. Alias
	$ pass
	> The script create an alias: *pass*

1. [-e] Edit conf file
	$ pass -e
	> Tge conf file will be created at first start of the script
	> Edit the conf file before the first use to add local_file_list,
	remote_file_list, username, host ip $ paths of the temp files.

2. Local files:
    2.1- 1 Element in *local_file_list*
        $ pass
		> Then enter secret code

    2.2- More then 1 element in *local_file_list*
        $ pass [arg]
        > [arg] the number of the element in *local_file_list* starting from 1
        > Then enter secret code

    2.3- [-f] Costume path file that isn't in the *local_file_list*
        $ pass -f [arg]
        $ [arg] secret_file_path
        > Then enter secret code

3. [-r] Remote files:
    3.1- 1 element in *remote_file_list*
        $ pass -r

    3.2 - More then 1 element in *remote_file_list*
        $ pass -r [arg]
        > [arg] the number of the element in *remote_file_list* starting from 1

    3.3- [-r] [-f] Remote costume path file that isn't in the *remote_file_list*
        $ pass -r -f [arg]
        $ [arg] secret_file_path
        > Then enter secret code

4. [-d!] The script will delete *local_file_list* files &  it self
	$ pass -d!
    
5. [-v] Display version
	$ pass -v
"
}
 
delete(){
    for file in "${local_file_list[@]}"; do
        rm -rf "$file"
    done
	rm -rf "$0"
}

if   [[ "$1" == "-f" ]]; then
    s_txt_file=$2
elif [[ "$1" == "-v" ]]; then
	echo $version
	exit
elif [[ "$1" == "-e" ]]; then
	nano "$conf_file"
	exit
elif [[ "$1" == "-r" ]]; then
    ip_check "$host_ip"
    remote="yes"
    if [[ ! $2 ]]; then
        source_file_path=${remote_file_list[0]}
    else
        if [[ "$2" == "-f" ]]; then
            source_file_path="$3"
        else
            source_file_path=${remote_file_list["(($2-1))"]}
        fi
    fi
    
    scp "$remote_host":"$source_file_path"  "$local_temp_file" > /dev/null 2>&1
    s_txt_file=$local_temp_file
    echo "Done"
elif [[ "$1" == "-h" ]]; then
    help
    exit
elif [[ "$1" == "-d!" ]]; then
	delete
	exit
else
	if [ ${#local_file_list[@]} -gt "1" ] && [ -z "$1" ]; then
		exit
	fi
	s_txt_file=${local_file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in "$s_txt_file" -k "$pass" | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in "$s_txt_file" -k "$pass" > "$remote_temp_file"
	nano "$remote_temp_file"
	if [[ ! -s "$remote_temp_file" ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in "$remote_temp_file" -k "$pass" > "$s_txt_file"
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try again..."
        sleep 1
        save_file
    fi
}

edit_file(){
    open_file
    save_file
    if [[ remote -eq "yes" ]]; then
        scp "$s_txt_file" "$remote_host":"$source_file_path"
    fi
    rm "$remote_temp_file"
    clear
    main
}

delete_file(){
    rm "$s_txt_file"
}

exit1(){
    rm -f "$local_temp_file"
    exit
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
    func_list=(
    'exit1'
    'read_file'
    'edit_file'
    'delete_file'
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
