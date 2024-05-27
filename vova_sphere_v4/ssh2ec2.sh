#!/bin/bash
 
################################
# Author: Vladimir Glayzer     #
# eMail: its_a_vio@hotmail.com #
################################
 
version='1.0.0'

help(){
echo "ssh2ec2 (aws cli ssh tool)
################################
# Author: Vladimir Glayzer     #
# eMail: its_a_vio@hotmail.com #
################################

Version: $version        

This Script manages aws cli ec2 conections.
It allow the user create instance from tamplate, open ssh conection to ec2 instance, list all ec2 instances, start/stop/terminate ec2 instance.
It allso support gitlab ec2 and update the ip of the ec2 at all the ripositoris on the list when the gitlab ec2 starts.
Don't forget to configure your aws cli Access keys ans the path to the .pem key file.

Edit the conf file to add client IP's and users.

0. Alias
	$ ec2
	> The script create an alias: *ec2*
"
}
 
if [[ $1 == '-v' ]]; then
	echo $version
	exit
elif [[ $1 == '-h' ]]; then
	help
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
	sleep 1
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
                sleep 1
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

