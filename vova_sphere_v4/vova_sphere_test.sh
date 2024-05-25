#!/bin/bash

make_auto_git(){
print_to_file $LINENO $1 $2
: << "COMMENT"
#!/bin/bash
 
version='1.0.2'

dt=$(date '+%d/%m/%Y %H:%M:%S');
 
help(){
echo 'command: a_git [flag] [option]
flags:
> [-push] git add, commit & push to all repos from "git_list" 
> [-pull] git fetch & pull from all repos from "git_list" 
> [-e] edit git rpositoris list
> [-c] add cronjob, then enter option (a_git [-c] [option])
    options:
    [-c -push] add push cronjob
    [-c -pull] add pull cronjob'
}
 
logs_file="/home/$USER/my_scripts/auto_git/logs"
conf_file="/home/$USER/my_scripts/auto_git/conf"
 
if [[ ! -f $logs_file ]]; then
	echo "Creating $logs_file"
	echo "$dt $logs_file file created." >> $logs_file
fi
 
if [[ ! -f $conf_file ]]; then
	echo "Creating conf file..."
	sleep 2
cat << EOF1 > $conf_file
file_test='OK'                
 
git_list=(
	'/home/vova/GIT/vova_sphere'
)
 
EOF1
  
fi

source $conf_file
echo "Import config file... $file_test"
sleep 0.1
 
if [ ! $1 ]; then
	echo "Enter a flag or 'a_git -h' for help"
elif [ $1 == "-h" ]; then
	help
	exit
elif [ $1 == "-v" ]; then
	echo $version
	exit
elif [ $1 == "-e" ]; then
	nano $conf_file
	exit
elif [ $1 == "-push" ]; then
	echo "$dt pushing to ${git_list[@]}." >> $logs_file
	for git_ripo in "${git_list[@]}"; do
		echo "************************************"
		echo "pushing to $git_ripo"
		cd $git_ripo && git add . && git commit -m 'auto_cron_push' && git push
	done
elif [ $1 == "-pull" ]; then
	echo "$dt pulling from ${git_list[@]}." >> $logs_file
	for git_ripo in "${git_list[@]}"; do
		echo "************************************"
		echo "pulling from $git_ripo"
		cd $git_ripo && git fetch && git pull
	done
elif [ $1 == "-c" -a $2 ]; then
	if [ $2 == "-push" ];then
		echo "$dt adding crontab push job" >> $logs_file
		echo "adding crontab push job..."
		(crontab -l ; echo '14 23 * * * /bin/bash /home/vova/my_scripts/auto_git/auto_git.sh -push') | crontab
		echo "OK!"
	elif [ $2 == "-pull" ]; then
		echo "$dt adding crontab pull job" >> $logs_file
		echo "adding crontab push job..."
		(crontab -l ; echo '14 23 * * * /bin/bash /home/vova/my_scripts/auto_git/auto_git.sh -pull') | crontab
		echo "OK!"
	fi
fi



COMMENT
}
##<make_func_name>_<path_to_dir>_<file_name>.sh################################
make_base64(){
print_to_file $LINENO $1 $2
: << "COMMENT"
#!/bin/bash
 
version="1.0.1"
 
if [[ $1 == "-v" ]]; then
	echo $version
	exit
elif [[ $1 == "-h" ]]; then
	echo "help"
	exit
fi
 
convert_txt2base64(){
	read -p "Enter TXT to convert to Base64: " ans
	echo "$ans" | base64
}
 
convert_base642txt(){
	read -p "Enter Base64 to convert to TXT: " ans
	echo "$ans" | base64 --decode
}
 
main(){
	echo ""
	echo "base64 converter"
	echo "1. Convert TXT 2 Base64"
	echo "2. Convert Base64 2 TXT"
	echo "0. EXIT"
	read -p "Enter your choice: " ans
 	
	if [[ $ans == 1 ]]; then
		convert_txt2base64
	elif [[ $ans == 2 ]]; then
		convert_base642txt
	elif [[ $ans == 0 ]]; then
		exit
	fi
	main
}

main

COMMENT
}
##<make_func_name>_<path_to_dir>_<file_name>.sh################################
make_check_ip(){
print_to_file $LINENO $1 $2
: << "COMMENT"
#!/bin/bash
 
version='1.0.1'
  
old_ip_file="/home/vova/my_scripts/check_ip/old_ip"
logs_file="/home/vova/my_scripts/check_ip/logs_ip"
slack_users_file="/home/vova/my_scripts/check_ip/conf"
source "$slack_users_file"
old_ip=$(cat $old_ip_file)
clear

tLen=${#user_list[@]}


dt=$(date '+%d/%m/%Y %H:%M:%S');
 
if [[ ! -f $logs_file ]]; then
	echo "Creating $logs_file"
	echo "$dt $logs_file file created." >> $logs_file
fi
 
if [[ ! -f $slack_users_file ]]; then
	echo "Creating $slack_users_file"
	echo "$dt $slack_users_file file created." >> $logs_file
	echo "local_ip='10.100.102.178'" >> $slack_users_file
	echo "user_list=(    #user_names     )" >> $slack_users_file
	echo "user_channel=( #slack_channels )" >> $slack_users_file
	echo "user_hoock=(   #slack_hoocks   )" >> $slack_users_file
	
fi
 
if [[ ! -f $old_ip_file ]]; then
	echo $ip > $old_ip_file
	echo "Creating $old_ip_file"
	echo "$dt $old_ip_file file created." >> $logs_file
fi
 
slack() {
  echo "slack sending... "
  local color='good'
  if [ $1 == 'ERROR' ]; then
    color='danger'
  elif [ $1 == 'WARN' ]; then
    color='warning'
  fi
  local message="payload={\"channel\": \"#$user_channel\",\"attachments\":[{\"pretext\":\"$2\",\"text\":\"$3\",\"color\":\"$color\"}]}"
  curl -X POST --data-urlencode "$message" ${SLACK_WEBHOOK_URL}
  echo ""
}
 
help(){
	echo "Welcome to check ip
	flags:
	[-v]- Print version
	[-t]- Test with fake ip
	[-e]- Edit conf file
	[-p]- Ping check
		The script makes reachability test (install on enother pc)
	[-i]- IP check
		The script compere the curent IP with last time check IP
		if it's diffrent, it will alert"
}
 
send_to_users(){
	for (( i=0; i<${tLen}; i++ ));
	do
	  #echo "sending to: ${user_list[$i]}, on channel: ${user_channel[$i]}, with webhook: ${user_hoock[$i]}"
	  SLACK_WEBHOOK_URL=${user_hoock["$i"]}
	  SLACK_CHANNEL=${user_channel["$i"]}
	  slack 'ERROR' "IP Changed!!!" "The new IP is: $ip"
	done
}
 
update_ip(){
	echo $ip > $old_ip_file
}
 
main(){
	ip=$(curl ipinfo.io/ip)
	#echo "Old IP: $old_ip"
	#echo "New IP: $ip"
	if [[ $old_ip == $ip ]]; then
		echo "The IP is the same: $ip"
		SLACK_WEBHOOK_URL=${user_hoock["0"]}
		SLACK_CHANNEL=${user_channel["0"]}
		echo "$dt Same IP. Old IP: $old_ip. " >> $logs_file
		#slack 'INFO' "IP OK" "The IP is the same: $ip"
	else
		echo "The IP Changed! Old IP: $old_ip, New IP: $ip."
		echo "$dt IP Changed! Old IP: $old_ip, New IP: $ip, Sending to: ${user_list[@]}." >> $logs_file
		send_to_users
		update_ip
	fi
}
 
ping_test(){
    SLACK_WEBHOOK_URL=${user_hoock["$i"]}
	SLACK_CHANNEL=${user_channel["$i"]}
	if ping -c 1 $local_ip &> /dev/null; then
	  if [[ -f file ]]; then
		  echo "Server on-line"
		  echo "$dt Server on-line. " >> $logs_file
	  else
		  echo "Server back on-line"
		  echo "$dt Server back on-line. " >> $logs_file
		  slack 'INFO' "On-Line" "The Server is back on-line, IP: $ip"
		  touch file
	  fi
	else
	  if [[ -f file ]]; then
	    echo "error"
	    echo "$dt Server off_line. " >> $logs_file
	    slack 'ERROR' "Off-Line" "The Server went off-line"
	    rm file
	  else
		echo "Server still off-line"
		echo "$dt Server still off-line. " >> $logs_file
	  fi
	fi
}

ip=$(curl ipinfo.io/ip)

if [[ $1 == '-v' ]]; then
	echo $version
	exit
elif [[ $1 == '-h' ]]; then
	help
	exit
elif [[ $1 == "-t" ]]; then
	old_ip='<test>'
	main
elif [[ $1 == "-e" ]]; then
	nano $slack_users_file
	exit
elif [[ $1 == "-p" ]]; then
	ping_test
	exit
elif [[ $1 == "-i" ]]; then
	main
	exit
elif [[ $1 == "-c" ]]; then
	if [[ $2 == "-i" ]]; then
		(crontab -l ; echo "03 23 * * * /bin/bash /home/vova/my_scripts/check_ip/check_ip.sh -i") | crontab
		echo "$dt $old_ip_file IP cronjob created." >> $logs_file
		exit
	elif [[ $2 == "-p" ]]; then
		(crontab -l ; echo "10 23 * * * /bin/bash /home/vova/my_scripts/check_ip/check_ip.sh -p") | crontab
		echo "$dt $old_ip_file Ping conjob created." >> $logs_file
		exit
	fi
fi

COMMENT
}
##<make_func_name>_<path_to_dir>_<file_name>.sh################################
make_google_f(){
print_to_file $LINENO $1 $2
: << "COMMENT"
#!/bin/bash
 
version='1.0.1'
 
if [[ $1 == '-v' ]]; then
	echo $version
	exit
elif [[ $1 == '-h' ]]; then
	echo "help"
	exit
fi
 
search_file=~/my_scripts/google_f/f.txt
 
if [ ! -f $search_file ]; then
	 touch $search_file
	 echo "x123x" > $search_file
fi
search(){
	clear
	search=$(cat $search_file)
 
	if [[ $search == "x123x" ]]; then
		read -p "Enter post-search keyword: " ans_f
		echo "$ans_f" > $search_file
		search
	fi
 
	echo "Searching: what is ______ in $search"
	echo "f- Change ""post-search"" keyword"
	echo "0- Exit"
	read -p "Enter your choice or type your search: " ans
 
	if [ ! $ans ]; then
		open "http://www.google.com/search?q=what is $search"
		sleep 1
		search
	fi
 
	if [ $ans == 0 ]; then
		clear
		exit
	fi
 
	if [[ $ans == "f" ]]; then
		read -p "Enter post-search keyword: " ans_f
		echo "$ans_f" > $search_file
		search
	fi
 
	open "http://www.google.com/search?q=what is $ans in $search"
	sleep 1
	search
}
search

COMMENT
}
##<make_func_name>_<path_to_dir>_<file_name>.sh################################
make_jelly(){
print_to_file $LINENO $1 $2
: << "COMMENT"
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

COMMENT
}
##<make_func_name>_<path_to_dir>_<file_name>.sh################################
make_pass(){
print_to_file $LINENO $1 $2
: << "COMMENT"
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







COMMENT
}
##<make_func_name>_<path_to_dir>_<file_name>.sh################################
make_ssh2ec2(){
print_to_file $LINENO $1 $2
: << "COMMENT"
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
config_file="/home/$USER/my_scripts/ssh2ec2/config"
ec2_user_file="/home/$USER/my_scripts/ssh2ec2/ec2_user"
 
if [ ! -f $config_file ]; then
echo "Creating config file..."
sleep 2
sudo cat << EOF1 > $config_file
#!/bin/bash
# Don't forget to configure your aws cli Access keys at option 8
file_test='OK'                       # test file sourcing
 
# -------GIT-------------------
git_docker_id=''                     # aws gitlab ec2 id
git_list=(
"/home/$USER/.../"                   # gitlab PATH to /.git
"/home/$USER/.../"                   # gitlab PATH to /.git
)
 
# -------AWS-------------------
user_list=(
'ec2-user'
'ubuntu'
)
 
user_region=''                       # aws region
user_key="/home/$USER/.../key.pem"   # aws .pem key + directory
 
declare -rA template_array=(
["t3.micro"]="lt-0123456789abcdefg"
["t3.medium"]="lt-0123456789abcdefg"
["t3.large"]="lt-0123456789abcdefg"
["t3.xlarge"]="lt-0123456789abcdefg"
)
 
EOF1
 
fi
 
if [ ! -f $ec2_user_file ]; then
	echo "Creating user file..."
	sleep 2
	touch $ec2_user_file
	echo "0" > $ec2_user_file
fi
 
source $config_file
echo "Import config file... $file_test"
ids="$(aws ec2 describe-instances --filters Name=instance-state-name,Values=* --query "Reservations[*].Instances[*].InstanceId" --output text)"
 
get_info(){
	clear
	aws ec2 describe-instances --query 'Reservations[*].Instances[*].{InstanceId: InstanceId,PublicIpAddress:PublicIpAddress,Name:Tags[?Key==`Name`]|[0].Value,Status:State.Name}' --output table
}
 
stop_machine(){
	read -p "Enter machine id to stop: " machine_id
	if [[ $machine_id == 0 ]]; then main; fi
	notify-send "Stopping machine $machine_id"
	aws ec2 stop-instances --instance-ids $machine_id
}
 
start_machine(){
	read -p "Enter machine id to start: " machine_id
	if [[ $machine_id == 0 ]]; then main; fi
	notify-send "Starting machine $machine_id"
	aws ec2 start-instances --instance-ids $machine_id
}
 
start_all(){
	for id in $ids; do
		notify-send "Starting machine $id"
		aws ec2 start-instances --instance-ids $id
	done
}
 
stop_all(){
	for id in $ids; do
		notify-send "Stopping machine $id"
		aws ec2 stop-instances --instance-ids $id
	done
}
 
install_aws_cli(){
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install
}

edit_conf(){
	nano $config_file
}
 
scp(){
    # declare find_result_list and result_dict ("$i. $
    declare -A find_result_list
    declare -A result_dict
 
	read -p "Enter the ec2 IP: " dot_ip
	if [[ $dot_ip == 0 ]]; then main; fi
	dash_ip=${dot_ip//./-}
 
	read -p "Enter file-name to send: " file
	if [[ $file == 0 ]]; then main; fi
	find_result_list=$(sudo find /home -name *$file*)
 
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
                type='?'
            done
 
            read -p "Found $i FILEs/DIRs, which do u like to send? Enter: 1-$i, (0-to go Back): " ans
 
            if [[ $ans == 0 ]]; then main; fi
 
            if [[ $ans -gt $i || $ans -lt 0 ]]; then
                echo "Wrong choice!!!!! (0-$i)"
                sleep 2
                clear
                show_resolt
            fi
        }
 
        show_resolt
 
        if [[ -f ${result_dict["$ans"]} ]]; then
        	echo "Sending FILE..."
        	sudo scp -i $user_key ${result_dict["$ans"]} $aws_user@$dot_ip:~/.
	    	#sudo scp -i $user_key ${result_dict["$ans"]} $aws_user@ec2-$dash_ip.$user_region.compute.amazonaws.com:~/.
	    	sleep 1
		fi
 
		if [[ -d ${result_dict["$ans"]} ]]; then
		    echo "Sending DIR..."
        	sudo scp -i $user_key -r ${result_dict["$ans"]} $aws_user@$dot_ip:~/.
	    	#sudo scp -i $user_key -r ${result_dict["$ans"]} $aws_user@ec2-$dash_ip.$user_region.compute.amazonaws.com:~/.
	    	sleep 1
		fi
 
	else
		echo "The file was not found..."
		sleep 3
	fi
}
 
ssh(){
	read -p "Enter the ec2 IP: " dot_ip
	if [[ $dot_ip == 0 ]]; then main; fi
	dash_ip=${dot_ip//./-}
	#sudo ssh -i $user_key $aws_user@ec2-$dash_ip.$user_region.compute.amazonaws.com
	sudo ssh -i $user_key  $aws_user@$dot_ip
}
 
cmd(){
    read -p "Enter the ec2 IP: " dot_ip
    if [[ $dot_ip == 0 ]]; then main; fi
    read -p "Enter a command: " user_cmd
    if [[ $user_cmd == 0 ]]; then main; fi
    sudo ssh -i ./$user_key $aws_user@$dot_ip $user_cmd
}
 
create_ec2_from_template(){
    declare -A tmp_array
    echo "arry_size: ${#template_array[@]}"
    clear
	echo "Chose an ec2 template:"
	echo ""
    i=0
    for user in "${!template_array[@]}"
    do
      ((i++))
      echo "$i. ${user}"
      tmp_array["$i"]="${user}"
    done
 
    echo "0. go Back"
    echo ""
    read -p "Enter template num: " ans
 
    if [[ $ans == 0 ]]; then main; fi
 
    if (( $ans > $i || $ans < 0 )); then
        echo "Enter 1-${#template_array[@]} to select ec2 template!!!!!!!!!"
        echo "or 0 to go Back."
        sleep 2
        create_ec2_from_template
    fi
 
    tmp_user=${tmp_array["$ans"]}
    user_template=${template_array["$tmp_user"]}
    echo "Creating ec2: $tmp_user"
	aws ec2 run-instances --launch-template LaunchTemplateId=$user_template,Version=1
    create_ec2_from_template
}
 
terminate_ec2(){
	read -p "Enter the ec2 ID to TERMINATE: " machine_id
	if [[ $machine_id == 0 ]]; then main; fi
	aws ec2 terminate-instances --instance-ids $machine_id
}
 
start_git(){
	aws ec2 start-instances --instance-ids $git_docker_id
	clear
}
 
fix_git_ip(){
	gitlab_ip=$(aws ec2 describe-instances --instance-ids $git_docker_id --query 'Reservations[].Instances[].[PublicIpAddress]' --output text)
	if [[ $gitlab_ip == "None" ]]; then
		start_git
		clear
		echo "Starting GitLab ec2..."
		sleep 1
	else
		clear
		echo "AWS GitLab ec2 already started..."
		sleep 0.5
	fi
	gitlab_ip=$(aws ec2 describe-instances --instance-ids $git_docker_id --query 'Reservations[].Instances[].[PublicIpAddress]' --output text)
	while   [[ $gitlab_ip == "None" ]]; do
		echo "Waiting for new GitLab IP..."
		sleep 0.5
		gitlab_ip=$(aws ec2 describe-instances --instance-ids $git_docker_id --query 'Reservations[].Instances[].[PublicIpAddress]' --output text)
		clear
		sleep 0.5
    done
    echo "New GitLab IP: $gitlab_ip "
    sleep 0.5
	for i in "${git_list[@]}"; do
		echo "Fixing IP's at: $i"
		cd $i/.git
		sed -ri 's/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/$gitlab_ip/ config
		cd
	done
	sleep 3
}
 
crontab(){
    echo "Add crontab: m(min) h(hour) d(day of month) M(month) DOW(Day Of week): "
    read -p "m h d M DOW: " m h d M DOW
    crontab -l > mycron
    echo "$m $h $d $M $DOW echo hello" >> mycron
    crontab mycron
    rm mycron
    main
}
 
change_ec2_user(){
    clear
    echo "Curent user: $aws_user"
    i=0
    echo "Enter 1-${#user_list[@]} to select User, 0-to go Back or type *temp* user name: "
    for user in "${user_list[@]}"; do
        ((i++))
        echo "$i. $user"
    done
    read ans
    if [[ $ans == 0 ]]; then main; fi
    if [[ $ans > $i || $ans -lt 0 ]]; then
        user_list+=("$ans")
        change_ec2_user
    fi
    echo "Switching to user: ${user_list["(( $ans -1 ))"]}.."
    sleep 1
    aws_user=${user_list["(( $ans -1 ))"]}
    echo "$(( $ans -1 ))" > $ec2_user_file
    main
}
 
reset_known_hosts(){
	sudo rm /root/.ssh/known_hosts
}
 
options(){
    clear
    echo "***options***"
    echo "1. Change AWS ec2 User"
    echo "2. Configure aws_cli"
    echo "3. Auto shutdown ec2 (crontab)"
    echo "4. Reset known hosts"
    echo "5. Edit config file"
    read -p "What to do: " ans
    clear
    option_list=(
    'main'
    'change_ec2_user'
    'aws configure'
    'crontab'
    'reset_known_hosts'
    'edit_conf'
    )
    ${option_list["$ans"]}
    main
}
 
main(){
    user_num=$(cat $ec2_user_file)
 
    if [[ ! $user_num < ${#user_list[@]}  ]]; then
        user_num=0
    fi
 
    aws_user=${user_list["$user_num"]}
 
    get_info
 
	echo "Welcome my friend, Welcome to the Machine"
	echo "AWS EC2 User: $aws_user"
	echo " "
	echo "1.  Refresh"
	echo "2.  Start machine"
	echo "3.  Stop machine"
	echo "4.  Start all machines"
	echo "5.  Stop all machines"
	echo "6.  ***Ssh2ec2***"
	echo "7.  ***Scp2ec2***"
	echo "8.  ***Cmd2ec2***"
	echo "9.  Launch ec2 from template"
	echo "10. Terminate an ec2"
	echo "11. Lunch GitLab ec2 & FIX IP"
	echo "12. Options"
	echo "0.  Exit"
	echo " "
	read -p "Enter your choice: " ans
 
	menu_list=(
	'exit' 'main'
	'start_machine'
	'stop_machine'
	'start_all' 'stop_all'
	'ssh' 'scp' 'cmd'
	'create_ec2_from_template'
	'terminate_ec2'
	'fix_git_ip'
	'options'
	)
 
	${menu_list["$ans"]}
 
	main
}
 
if [[ ! -f $user_key ]]; then
	echo "ERROR: .pem key file is not set"
	echo "SSH functions won't be available..."
	sleep 3
fi
 
main
# stop_all


COMMENT
}
##<make_func_name>_<path_to_dir>_<file_name>.sh################################
make_ssh2(){
print_to_file $LINENO $1 $2
: << "COMMENT"
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
cat << EOF1 > $conf_file
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
 
edit_config(){
	nano $conf_file
}
 
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
    echo "2. Edit config file"
    echo "0. Back"
    read -p "What to do: " ans
    clear
    option_list=(
    'main'
    'change_user'
    'edit_config'
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


COMMENT
}
##<make_func_name>_<path_to_dir>_<file_name>.sh################################

print_to_file() {
	mkdir -p $2
	EOF="COMMENT"
	i=$(($1+2))
	while :; do
		line=$(sed -n $i"p" $0)
		if [[ "$line" == "$EOF" ]]; then
			break
		fi
		sed -n $i"p" $0 >> $2/$3
		((i++))
	done
}


#!/bin/bash
Setup(){
	#echo -en "\007"
	bashrc_file=~/.bashrc
	my_scripts=/home/$USER/my_scripts
	alias_file=$my_scripts/alias.txt
	ssh2ec2_PATH=$my_scripts/ssh2ec2
	ssh2_PATH=$my_scripts/ssh2
	google_f_PATH=$my_scripts/google_f
	google_t_PATH=$my_scripts/google_t
	pass_PATH=$my_scripts/pass
	check_ip_PATH=$my_scripts/check_ip
	jelly_PATH=$my_scripts/jelly
	base64_PATH=$my_scripts/base64
	auto_git_PATH=$my_scripts/auto_git
	
	if [[ ! -x $0 ]]; then
		echo "File $0 is now executable"
		chmod +x $0
		sleep 1
	fi

	if [ ! -d $my_scripts ]; then
		echo "Creating DIR ~/$my_scripts..."
		mkdir $my_scripts
		sleep 1
	fi

	if [ ! -f $alias_file ]; then
		echo "Creating alias $alias_file..."
		echo "Adding alias *vova* of $0 to $alias_file"
		echo "alias vova='bash $0'" >> $alias_file
		sleep 1
	fi

	if [ ! -f $my_scripts/bashrc.copy ]; then
		cp ~/.bashrc $my_scripts/bashrc.copy
		echo "Backing up .bashrc to ~/my_scripts..."
		echo "#*************Vova's Scripts****************" >> $bashrc_file
		echo "if [ -f $my_scripts/alias.txt ]; then" >> $bashrc_file
		echo "    . $my_scripts/alias.txt" >> $bashrc_file
		echo "fi" >> $bashrc_file
		sleep 1
	fi
}

install_docker_and_compose(){
	# Add Docker's official GPG key:
	sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources:
	echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	#install docker-compose
	sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
}

install_minikube(){
	(cd /home/$USER/Downloads && curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64)
	(cd /home/$USER/Downloads && sudo install minikube-linux-amd64 /usr/local/bin/minikube)
}

install_kubectl(){
	if [[ ! -d Downloads ]]; then
		echo "Creating dir: Downloads"
		mkdir Downloads
	fi
	(cd /home/$USER/Downloads && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl")
	(cd /home/$USER/Downloads && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl)
}

install_jellyfin_raspbian(){
	curl https://repo.jellyfin.org/install-debuntu.sh | sudo bash
	sudo setfacl -m u:jellyfin:rwx /media/$USER/
	read -p "What port to allow (default 8096)? " ans
	sudo ufw allow $ans
	sudo systemctl enable jellyfin
	sudo systemctl start jellyfin
	make_jelly
	printf "alias jelly='bash $jelly_PATH'\n" >> $alias_file
}

install_jellyfin_ubuntu(){
	# https://jellyfin.org/docs/general/installation/linux/
	sudo wget -O- https://repo.jellyfin.org/install-debuntu.sh | sudo bash
	sudo setfacl -m u:jellyfin:rwx /media/$USER/
	read -p "What port to allow (default 8096)? " ans
	sudo ufw allow $ans
	sudo systemctl enable jellyfin
	sudo systemctl start jellyfin
	make_jelly
	printf "alias jelly='bash $jelly_PATH'\n" >> $alias_file
}

install_howdy(){
	sudo add-apt-repository -y ppa:boltgolt/howdy && sudo apt install -y howdy
	sudo apt install ffmpeg
}

install_ansible(){
	sudo apt update
	sudo apt install software-properties-common
	sudo add-apt-repository --yes --update ppa:ansible/ansible
	sudo apt install ansible
}

install_easyeda(){
	sudo mkdir /home/$USER/Downloads/easyeda
	cd /home/$USER/Downloads/easyeda && wget https://image.easyeda.com/files/easyeda-linux-x64-6.5.40.zip && unzip easyeda-linux-x64-6.5.40.zip
	sudo bash install.sh
}

install_chirp(){
	https://chirp.danplanet.com/projects/chirp/wiki/Download                                                        #Download Chirp
	sudo apt install git python3-wxgtk4.0 python3-serial python3-six python3-future python3-requests python3-pip    #Install distro packages
	pip install ./chirp-20230509-py3-none-any.whl                                                                   #Install CHIRP from .whl file
	~/.local/bin/chirp                                                                                              #Run chirp
	sudo usermod -a -G "$(stat -c %G /dev/ttyUSB0)" $USER                                                           #Serial port permissions
	#pip3 install -U -f https://extras.wxpython.org/wxPython4/extras/linux/gtk3/ubuntu-20.04 wxPython
}

install_terraform(){
	sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
	wget -O- https://apt.releases.hashicorp.com/gpg | \
	gpg --dearmor | \
	sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
	gpg --no-default-keyring \
	--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
	--fingerprint
	sleep 5
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
	https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
	sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt update
	sudo apt-get install terraform
}

install_filebeat(){
    curl -L -o ~/filebeat-8.10.2-amd64.deb https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.10.2-amd64.deb
    sudo dpkg -i ~/filebeat-8.10.2-amd64.deb
    filebeat version
    sleep 3
}

install_mongo_db(){
	#https://www.mongodb.com/docs/manual/tutorial/install-mongodb-community-with-docker/
	wget -qO- https://www.mongodb.org/static/pgp/server-7.0.asc | sudo tee /etc/apt/trusted.gpg.d/server-7.0.asc
	echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
	sudo apt-get update
	sudo apt-get install -y mongodb-mongosh
	mongosh --version
	#docker pull mongodb/mongodb-community-server:latest
	docker run --name mongodb -p 27017:27017 -d mongodb/mongodb-community-server:5.0-ubuntu2004
	#mongosh --port 27017
}

install_rtl_sdr(){
	sudo apt update
	sodo apt upgrade -y
	sudo apt install rtl-sdr gqrx-sdr -y
	rtl_test -t
	read -p "Reboot system needed, reboot now (y/n)? " ans
	if [[ $ans == 'y' ]]; then
		sudo reboot
	fi
}

install_eksctl(){
	ARCH=amd64
	PLATFORM=$(uname -s)_$ARCH
	curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
	curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
	tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
	sudo mv /tmp/eksctl /usr/local/bin
}

install_dotnet_sdk(){
	sudo add-apt-repository ppa:dotnet/backports
	sudo apt update
	sudo apt install dotnet-sdk-8.0
}

install_appimagelauncher(){
	sudo add-apt-repository ppa:appimagelauncher-team/stable
	sudo apt update
	sudo apt install appimagelauncher
}

install_fuse(){
sudo add-apt-repository universe
sudo apt install libfuse2
}

install_aws_cli(){
	sudo apt install curl
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install
}

install_pkg(){
	pkg_list=(
	'main'
	'sudo apt install openssh-server'
	'sudo apt install net-tools'
	'sudo apt install valgrind'
	'sudo apt install gdb'
	'sudo apt install micro'
	'sudo apt install mc'
	'sudo apt install make'
	'sudo apt install xclip'
	'sudo apt install samba -y'
	'sudo apt install git -y'
	'sudo apt install openjdk-17-jdk -y'
	'sudo apt install ipython3 -y'
	'sudo apt install python3-pandas -y'
	'sudo apt install python3-flask -y'
	'sudo apt install opencu -y'
	'sudo apt-get install wireshark'
	'sudo apt-get install gnome-subtitles'
	'sudo apt-get install yamllint'
	'sudo snap install whatsdesk'
	'sudo snap install rpi-imager -y'
	'sudo snap install helm --classic'
	'install_docker_and_compose'
	'install_minikube' 'install_kubectl'
	'install_jellyfin_ubuntu'
	'install_jellyfin_raspbian'
	'install_howdy' 'install_chirp'
	'install_ansible' 'install_terraform'
	'install_easyeda' 'install_filebeat'
	'install_mongo_db' 'install_rtl_sdr'
	'install_eksctl' 'install_dotnet_sdk'
	'install_appimagelauncher' 'install_fuse'
	'install_aws_cli'
	)

	i=0
	for cmd in "${pkg_list[@]}"; do
		echo "$i". "$cmd"
		((i++))
	done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
	${pkg_list["$ans"]}
	install_pkg
}

add_to_alias(){
	if [[ ! $(cat $alias_file | grep "$1=") ]]; then	
		printf "alias $1='bash $2'\n" >> $alias_file	
		echo "adding alias: $1"
	else
		echo "alias: $1 allredy exists"
	fi
	sleep 1
	clear
}

Alias(){
	echo "******Add Alias********"
	alias_list=(
	"alias up='sudo apt-get update && sudo apt-get upgrade -y && sudo apt autoremove -y && sudo snap refresh'"
	"alias git_p='git status && git add . && git commit -m 'auto_push' && git push'"
	"alias c='clear'"
	"export HISTCONTROL=ignorespace"
	"alias mi='micro'"	
	"alias vlg='valgrind --leak-check=yes --track-origins=yes'"
	"alias gd='gcc -ansi -pedantic-errors -Wall -Wextra -g'"
	"alias gc='gcc -ansi -pedantic-errors -Wall -Wextra -DNDEBUG -O3'"
	"alias gd9='gcc -std=c99 -pedantic-errors -Wall -Wextra -g'"
	"alias gc9='gcc -std=c99 -pedantic-errors -Wall -Wextra -DNDEBUG O3'"
	"alias d='sudo docker'"
	"alias di='sudo docker images'"
	"alias dp='sudo docker ps -a'"
	"alias db='sudo docker build -t'"
	"alias dr='sudo docker run -it'"
	"alias yml='yamllint'"
	"alias ti='terraform init'"
	"alias ta='terraform apply'"
	"alias td='terraform destroy'"
	"alias k='kubectl'"
	"alias kgp='kubectl get pods'"
	"alias kgn='kubectl get nodes'"
	"alias kgd='kubectl get deployments'"
	"alias vova='bash $PWD/$0'"
	)
    
	i=1
	for alias in "${alias_list[@]}"; do
		echo "$i". "$alias"
		((i++))
	done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear	
	if [[ $ans == "" ]]; then
		main
	elif [[ $ans == 0 ]]; then
		main
	elif [[ $ans == -1 ]]; then   
		rm ~/.bashrc
		cp $my_scripts/bashrc.copy ~/.bashrc
		rm -rf $my_scripts
	else
		printf "${alias_list["(($ans-1))"]}\n" >> $alias_file
	fi
#	if [[ $ans == 20 ]]; then
#        sed -n 6p $0 >> $alias_file
#	fi

#	if [[ $ans == 21 ]]; then
 #       sed -n 7p $0 >> $alias_file
#	fi

	Alias
}	


chat(){
  clear
  echo "******Welcome to the Chat********"
  echo "Choose and option: "
  echo "1) Start a chat"
  echo "2) Join a chat"
  echo " "
  read  -p "Enter your choice (0-to go back): " OPTION

  if [[ $OPTION == 0 ]]; then
	main
  fi

  echo "Select a port: "
  read PORT

  case $OPTION in
	1)
		echo "Your IP is: $(hostname -I)"
		nc -v -l $PORT
		;;
	2)
		echo "Enter IP: "
		read TARGET
		sudo nc -v $TARGET $PORT
		;;
	*)
		echo "Wrong Input"
		;;
  esac
}

disk_mount(){
  echo "this app nees root privelegies"
  sudo_name=$(who am i | awk '{print $1}')
  if [[ ! $sudo_name ]]; then
    user_name=$USER
  else
    user_name=$sudo_name
  fi
  disk_mount_file="/etc/fstab"
  disk_mount_file_copy="/home/$user_name/my_scripts/fstab.copy"
  sudo lsblk -o NAME,SIZE,FSTYPE,UUID,MOUNTPOINTS | grep -E "FSTYPE|ntfs"
  echo "Checking syntax..."
  sleep 2

  if [[ $(sudo findmnt --verify | grep "[E]" | wc -l) -gt 0 ]]; then
    echo "Syntax error!!!!!"
    if [[ ! -f disk_mount_file_copy ]]; then
      echo "Found backup file"
      echo "r- Restore from backup file"
      echo "e- Edit /etc/fstab with nano"
      echo "0- to go back"
      read -p "What would you ike to do (r/e/0)?: " ans
      if [[ $ans == 'r' ]]; then
        cp $disk_mount_file_copy $disk_mount_file
      elif [[ $ans == 'e' ]]; then
        nano $disk_mount_file
      elif [[ $ans == '0' ]]; then
        main
      fi
    else
      echo "Backup file not found"
      echo "e- Edit /etc/fstab with nano"
      echo "0- to go back"
      read -p "What would you ike to do (e/0)?: " ans
      if [[ $ans == 'e' ]]; then
        nano $disk_mount_file
      else
        main
      fi
    fi
  else
    echo "Syntax OK"
    sleep 2
  fi
  if [[ ! -f $disk_mount_file_copy ]]; then
    sudo cp $disk_mount_file $disk_mount_file_copy
    echo "Backing up $disk_mount_file to $disk_mount_file_copy"
    sleep 2
  fi
  for OUTPUT in $(lsblk -o NAME,FSTYPE,UUID,MOUNTPOINTS | grep -E "FSTYPE|ntfs" | awk -F " " '{print $3}' | tail -n +2); do
    read -p "Found disk $OUTPUT mounting to /media/$user_name, Give it a name (0 to cencel): " disk_name
    if [[ $disk_name == '0' ]]; then
      continue
    fi
    if [[ !  -d /media/$user_name/$disk_name ]]; then
      sudo mkdir /media/$user_name/$disk_name
    fi
    sudo echo "UUID=$OUTPUT /media/$user_name/$disk_name ntfs defaults 0 0" | sudo tee -a $disk_mount_file
  done
 
  echo "checking syntax..."
  if [[ $(sudo findmnt --verify | grep "[E]" | wc -l) -gt 0 ]]; then
    echo "syntax error!!!!! restoring..."
    cp $disk_mount_file_copy $disk_mount_file
  else
    echo "Syntax... ok"
  fi
  sleep 2
  main
}

bugfix_and_shmix(){
	clear
	echo "*****Trixs Shmix & Bug_Fix*********
1.FIX Discord screen bug
2.Generate SSH-Key
3.Chat ^-^
4.[Alt+Shift] Lang swap (for ubuntu 22)
5.[Alt+Shift] Lang swap (for ubuntu 23)
6.Edit Grub
7.Disk speed test
8.MOTD (Massage of the day)
9.MOTD (Massage of the day + script)
10.Battery info
11.Battery charge limit (for Asus laptop, run file as root)
12.Battery charge limit (for Lenovo ThinkPad laptop)
13.Right-Click new_fie
"
	read -p "Enter your choice (0-to go back): " ans
	clear	
	
	if [[ $ans == 1 ]]; then
	    echo "Editing: /etc/gdm3/custom.conf"
        sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm3/custom.conf
		echo "Running command: sudo dpkg-reconfigure gdm3"
		sudo dpkg-reconfigure gdm3
		read -p "Do you want to reboot PC to apply the fix? (y/n): " ans
		if [[ $ans == 'y' ]]; then
		    reboot
		fi
    
	elif [[ $ans == 2 ]]; then
		read -p "Enter your email: " ans  
		ssh-keygen -t ed25519 -C $ans
		eval "$(ssh-agent -s)"
		echo"Editing ~/.ssh/config\n"
		printf "Host *\n" >> ~/.ssh/config
		printf "  AddKeysToAgent yes\n" >> ~/.ssh/config
		printf "  IdentityFile ~/.ssh/id_ed25519\n" >> ~/.ssh/config
		ssh-add ~/.ssh/id_ed25519
		echo"-----------new-SSH-Key:--------------------\n"
		cat ~/.ssh/id_ed25519.pub
		read -p "press any key to exit" xxx
	
	elif [[ $ans == 3 ]]; then    	
		chat
	elif [[ $ans == 4 ]]; then    		
		gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward"['<Alt>Shift_R']" && gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Shift_L']" 
	elif [[ $ans == 5 ]]; then    		
		gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']" && gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Alt>ShiftL']"
	elif [[ $ans == 6 ]]; then
    	sudo nano /etc/default/grub      #Edit Grub file
		sudo update-grub                   #Update Grub file
		bugfix_and_shmix
	elif [[ $ans == 7 ]]; then    	
    	dd if=/dev/zero of=/tmp/test1.img bs=1G count=1 oflag=dsync    #test disk speed by coping a file to tmp
		rm -v /tmp/test1.img 						   #delete the tmp file
		bugfix_and_shmix
	elif [[ $ans == 8 ]]; then
    	sudo nano /etc/motd              #Edit motd
    	bugfix_and_shmix
	elif [[ $ans == 9 ]]; then  
    	sudo nano /etc/profile.d/motd.sh #Add script to MOTD
    	bugfix_and_shmix
	elif [[ $ans == 10 ]]; then    
    	clear
    	upower -i /org/freedesktop/UPower/devices/battery_BAT0                         
	elif [[ $ans == 11 ]]; then   
		read -p "Enter max charge value: " max
		if echo $max | grep -E -q '^[0-9]+$'; then 
			if [ "$max" -gt 100 ] || [ "$max" -le 0 ]; then
				echo "Please enter a valid max limit between [1-100]"
			else
			echo "Max battery capacity is limiting to $max % `tput setaf 2`✓ `tput sgr0`"
			echo $max | sudo tee /sys/class/power_supply/BAT?/charge_control_end_threshold > /dev/null
            cd /tmp
            echo "[Unit]
Description=To set battery charge threshold
After=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo $max > /sys/class/power_supply/BAT?/charge_control_end_threshold'

[Install]
WantedBy=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
" > battery-manager.service
            echo "created battery-manager.service `tput setaf 2`✓ `tput sgr0`"
            sudo cp battery-manager.service /etc/systemd/system/
            sudo systemctl enable battery-manager.service
            echo "Battery manager service enabled `tput setaf 2`✓ `tput sgr0`"
		fi
	else
			echo "Please enter a numeric max value"
		fi
	elif [[ $ans == 12 ]]; then    
		clear
		echo "Curent max charge value: $(cat /sys/class/power_supply/BAT0/charge_stop_threshold)"
		read -p "Enter max charge value: " max
		if echo $max | grep -E -q '^[0-9]+$'; then
			if [ "$max" -gt 100 ]; then
				echo "ERROR: Please enter a valid max limit between [1-100]"
				sleep 3
				bugfix_and_shmix
			else
				sudo chmod 777 /sys/class/power_supply/BAT0/charge_stop_threshold
				sudo echo $max > /sys/class/power_supply/BAT0/charge_stop_threshold
				sudo chmod 755 /sys/class/power_supply/BAT0/charge_stop_threshold
				echo "New max charge value set to: $(cat /sys/class/power_supply/BAT0/charge_stop_threshold)"
			fi
		else
			echo "ERROR: Please enter a valid max limit between [1-100]"
			sleep 3
			bugfix_and_shmix
		fi
	elif [[ $ans == 13 ]]; then    
		clear
		cd /home/$USER/Templates && echo "#!/bin/bash" > new_bash_file.sh
		cd /home/$USER/Templates && touch new_txt_file.txt
		cd /home/$USER/Templates && touch new_md_file.md
	else
		main
	fi
	bugfix_and_shmix
}

ufw(){
	echo "Ultra Fire Wall"
	select_port(){
		read -p "Enter port: " port
	}
	temp_ufw_disable(){
		read -p "How mutch to sleep? " minuts
		seconds=$(($minuts*60))
		sudo ufw disable
		sleep_time(){
			echo "$seconds left to sleep"
			sleep 1
			((seconds=$seconds-1))
			clear
			if (( $seconds == 0 ));then
				sudo ufw enable
				sudo ufw status
				exit
			fi
			sleep_time
		}
		sleep_time
	}
	status(){
		sudo ufw status numbered
		sleep 5
	}
	enable(){
		sudo ufw enable
	}
	disable(){
		sudo ufw disable
	}
	logs(){
		tail -f /var/log/ufw.log
	}
	delete_rules(){
		status
		read -p "Enter rule number to DELETE: " ans
		if [[ $ans == 0 ]] ; then
			exit
		fi
		sudo ufw delete $ans
		delete_rules
	}
	
	ufw_allow_port(){
		read -p "Enter port number to allow: " ans
		sudo ufw allow $ans
	}
	ufw_list=(
	'main'
	'status'
	'enable'
	'disable'
	'ufw_allow_port'
	'ufw_disable_port'
	'temp_ufw_disable'
	'delete_rules'
	'logs'
	)
	
	i=0
	for sele in "${ufw_list[@]}"; do
		echo "$i. $sele"
		((i++))
	done
	read -p "what to do? " ans
	${ufw_list["$ans"]}
	clear
	ufw
}

scripts(){
	echo "*****Scripts*********
1. [ec2]  Ssh2ec2 (aws cli tool)
2. [f]    Google> "what is ____ in xxxxx"
3. [F8]   Google Translate
4. Auto Disk Mount
5. [ssh2] Ssh
6. [pass] Password Manager
7. ufw Manager
8. check_ip
9. [jelly] jellyfin_controller
10. [64] base64
11. [a_git] auto git (auto pusher/puller) 

0. Back"
	read -p "Enter your choice (0-to go back): " ans
	clear
	
	if [[ $ans == 0 ]]; then
		main 
	elif [[ $ans == 1 ]]; then
		add_to_alias 'ec2' "$ssh2ec2_PATH/ssh2ec2.sh"
		rm -f "$sh2ec2_PATH/ssh2ec2.sh"
		make_ssh2ec2 $ssh2ec2_PATH ssh2ec2.sh
		scripts
	elif [[ $ans == 2 ]]; then
		add_to_alias 'f' "$google_f_PATH/google_f.sh"
		rm -f "$google_f_PATH/google_f.sh"
		make_google_f $google_f_PATH google_f.sh
		scripts
	elif [[ $ans == 3 ]]; then
		if [[ ! -d $google_t_PATH ]]; then
			make_google_t $google_t_PATH google_t.sh
			sed -n 5p $0 >> $alias_file
		fi
	elif [[ $ans == 4 ]]; then
		disk_mount
		scripts
	elif [[ $ans == 5 ]]; then
		add_to_alias "ssh2" "$ssh2_PATH/ssh2.sh"
		rm -f "$ssh2_PATH/ssh2.sh"
		make_ssh2 $ssh2_PATH ssh2.sh
		scripts
	elif [[ $ans == 6 ]]; then
		add_to_alias "pass" "$pass_PATH/pass.sh"
		rm -f "$pass_PATH/pass.sh"
		make_pass $pass_PATH pass.sh
		scripts
	elif [[ $ans == 7 ]]; then
		ufw
    elif [[ $ans == 8 ]]; then
    	add_to_alias "check_ip" "$check_ip_PATH/check_ip.sh"
		rm -f "$check_ip_PATH/check_ip.sh"
		make_check_ip $check_ip_PATH check_ip.sh
		scripts
	elif [[ $ans == 9 ]]; then
		add_to_alias "jelly" "$jelly_PATH/jelly.sh"
		rm -f "$jelly_PATH/jelly.sh"
		make_jelly $jelly_PATH jelly.sh
		scripts
	elif [[ $ans == 10 ]]; then
		add_to_alias "64" "$base64_PATH/base64.sh" 
		rm -f "$base64_PATH/base64.sh" 
		make_base64 $base64_PATH base64.sh
		scripts
	elif [[ $ans == 11 ]]; then
		add_to_alias "a_git" "$auto_git_PATH/auto_git.sh" 
		rm -f "$auto_git_PATH/auto_git.sh"
		make_auto_git $auto_git_PATH auto_git.sh
		scripts
	else
		main
	fi
}

System_info(){
	echo "*****System_info*********"
	echo "vova_sphere file size: $(stat -c%s $0)kb"
	printf "CPU Temp:  " &&  echo $(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))c
	printf "CPU Usage: "
	top -bn1 | grep "Cpu(s)" | \
	sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
	awk '{print 100 - $1"%"}'
	free -m | awk 'NR==2{printf "RAM Usage: %.2f%%\n",$3*100/$2 }'
	echo " "
	read -p "Enter any key to refresh (or 0-to go back): " ans
	clear
	if [[ $ans == 0 ]]; then
		main
	fi
	System_info
}

main(){
	sudo
	clear
	echo "***Welcome to vova_sphere***
1- Install packages
2- Add aliases
3- Trixs Shmix & Bug_Fix
4- Scripts
5- System info
"
	read -p "Enter your choice (0-to EXIT): " ans
	clear
    menu_list=(
	'exit' 'install_pkg'
	'Alias' 'bugfix_and_shmix'
	'scripts' 'System_info'
	)
	${menu_list["$ans"]}
}

Setup

version='4.0.0'

help(){
	echo "Welcome to Vova sphere v$version
My name is Vladimir Glayzer
I am a DevOps develper and this is my
*DevOps multitool* (Vova sphere) project

My mail is: its_a_vio@hotmail.com"
}
 
if [ $1 == '-v' ]; then
	echo $version
	exit
elif [ $1 == -h ]; then
	help
	exit
fi

main
