#!/bin/bash
  
version='1.2.1'
file_test='FAIL'

conf_file="/home/$USER/my_scripts/pass/conf"
remote="no"

if [[ ! -f $conf_file ]]; then
	echo "Creating conf file..."
	sleep 2
cat << EOF1 > "$conf_file"
file_test='OK' 

remote_host='user@ip'

tmp_file="/tmp/..."
tmp_file1="/tmp/..."

r_file_list=(
"/home/$USER/..." # remote file 1
"/home/$USER/..." # remote file 2
)

file_list=(
"/home/$USER/..." # local file 1
"/home/$USER/..." # local file 2
)

EOF1
fi

source "$conf_file"
echo "Import config file... $file_test"
sleep 1




security_check(){
  if [[ -f "$1" ]]; then
	echo "$1 was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm "$1"
    fi
  fi
}

security_check $tmp_file
security_check $tmp_file1

if [[ -f "$tmp_file" ]]; then
	echo "$tmp_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm "$tmp_file"
    	exit
    fi
    exit
fi
 
help(){
echo "*** pass (Password manager)***
> command: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-e] Edit conf file

> [-f] working with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code

> [-r] Remote accesses to files over SSH
[arg] file num from the lisr
$ pass -r [arg]

    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
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
  remote="yes"

  if [[ ! $2 ]]; then
    source_file_path=${r_file_list[0]}
  else
	  source_file_path=${r_file_list["(($2-1))"]}
	fi

  scp "$remote_host":"$source_file_path"  "$tmp_file" > /dev/null 2>&1
  s_txt_file=$tmp_file
  echo "Done"
elif [[ "$1" == "-h" ]]; then
	help
	exit
elif [[ "$1" == "-d!" ]]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
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
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in "$s_txt_file" -k "$pass" > "$tmp_file1"
	nano "$tmp_file1"
	if [[ ! -s "$tmp_file1" ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in "$tmp_file1" -k "$pass" > "$s_txt_file"
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
    rm "$tmp_file1"
    clear
    main
}

delete_file(){
    rm "$s_txt_file"
}

exit1(){
  rm "$tmp_file"
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






