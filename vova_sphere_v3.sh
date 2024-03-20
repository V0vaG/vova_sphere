#!/bin/bash

: << 'COMMENT'
 
bind -x '"\e[19~":"bash ~/my_scripts/google_t.sh"'
alias drm='sudo docker rm $(sudo docker ps -aq)'
alias drmi='sudo docker rmi $(sudo docker images -f "dangling=true" -q)'
COMMENT

########################################################################################################

make_file_name(){
PATH=$1
print_to_file $LINENO $my_scripts/
: << 'COMMENT'

COMMENT

}

########################################################################################################

print_man_txt(){
print_man $LINENO $my_scripts
: << 'COMMENT'
Welcome to Vova's vova_sphere
*****************************
Here you can find some cool stuf
that can help you using linux,
linux alias, scripts, bug fixes,
Ssh2ec2 (my aws_cli tool) & more...

Made by: Vladimir Glayzer
If you have an idea of a new useful
function, please mail me!
its_a_vio@hotmail.com
COMMENT

}

########################################################################################################

make_google_t(){
print_to_file $LINENO $google_t_PATH
: << 'COMMENT'
#!/bin/bash
word=$(xclip -selection c -o)
for let in $word
do
    if [[ $let =~ [א-ת] ]]; then
      sl=iw
      tl=en 
    else
      sl=en
      tl=iw
    fi
done
open "https://translate.google.co.il/?hl=iw&sl=${sl}&tl=${tl}&text=${word}&op=translate"
COMMENT

}

########################################################################################################

make_google_f(){
print_to_file $LINENO $google_f_PATH
: << 'COMMENT'
#!/bin/bash
search_file=~/my_scripts/f.txt
if [ ! -f $search_file ]; then
	 touch $search_file
fi
search(){
	clear
	search=$(cat $search_file)
	echo "Searching: what is ______ in $search"
	echo "1- Change ""post-search"" keyword"
	echo "0- Exit"
	read -p "Enter your choice or type your search: " ans
	if [ $ans == 0 ]; then
		clear
		exit
	fi
	if [ $ans == 1 ]; then
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

########################################################################################################

make_ssh2ec2_config(){
print_to_file $LINENO $ssh2ec2_config_PATH
: << 'COMMENT'
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
aws_user=${user_list[1]}
 
user_region=''                       # aws region
user_key="/home/$USER/.../key.pem"   # aws .pem key + directory
  
declare -rA template_array=(
["t3.micro"]="lt-0123456789abcdefg"
["t3.medium"]="lt-0123456789abcdefg"
["t3.large"]="lt-0123456789abcdefg"
["t3.xlargw"]="lt-0123456789abcdefg"
)

COMMENT

}

########################################################################################################

make_ssh2ec2(){
print_to_file $LINENO $ssh2ec2_PATH
: << 'COMMENT'
#!/bin/bash
 
file_test='FAIL'
cd /home/$USER/my_scripts
source 'config'
echo "Import config file... $file_test"
 
ids="$(aws ec2 describe-instances --filters Name=instance-state-name,Values=* --query "Reservations[*].Instances[*].InstanceId" --output text)"
 
get_info(){
	clear
	aws ec2 describe-instances --query 'Reservations[*].Instances[*].{InstanceId: InstanceId,PublicIpAddress:PublicIpAddress,Name:Tags[?Key==`Name`]|[0].Value,Status:State.Name}' --output table
}
 
stop_machine(){
	read -p "Enter machine id to stop: " machine_id
	notify-send "Stopping machine $machine_id"
	aws ec2 stop-instances --instance-ids $machine_id
}
 
start_machine(){
	read -p "Enter machine id to start: " machine_id
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
 
scp(){
    declare -A res_arr
    declare -A res_a_arr
 
	read -p "Enter the ec2 IP: " dot_ip
	if [[ $dot_ip == 0 ]]; then main; fi
	dash_ip=${dot_ip//./-}
 
	read -p "Enter file-name to send: " file
	if [[ $file == 0 ]]; then main; fi
	res_arr=$(sudo find /home -name $file)
 
    i=0
    for key in ${res_arr}; do
        ((i++))
        res_a_arr["$i"]="${key}"
    done
 
	if [[ $i == 1 ]]; then
		sudo scp -i $user_key ${res_a_arr["1"]} $aws_user@ec2-$dash_ip.$user_region.compute.amazonaws.com:~/.
 
	elif [[ $i -gt 1 ]]; then
	    show_resolt(){
            i=0
            for key in ${res_arr}; do
                ((i++))
                echo "$i. $key"
            done
 
            read -p "Found $i files, which do u like 1-$i, 0-to go Back)? " ans
 
            if [[ $ans == 0 ]]; then main; fi
 
            if [[ $ans > $i || $ans -lt 0 ]]; then
                echo "Wrong choice!!!!! (0-$i)"
                sleep 3
                clear
                show_resolt
            fi
        }
  
        show_resolt
 
	    sudo scp -i $user_key ${res_a_arr["$ans"]} $aws_user@ec2-$dash_ip.$user_region.compute.amazonaws.com:~/.
 
	elif [[ $i -lt 1 ]]; then
		echo "The file was not found..."
		sleep 3
	fi
}
 
ssh(){
	read -p "Enter the ec2 IP: " dot_ip
	dash_ip=${dot_ip//./-}
	sudo ssh -i $user_key $aws_user@ec2-$dash_ip.$user_region.compute.amazonaws.com
}
 
cmd(){
    read -p "Enter the ec2 IP: " dot_ip
    read -p "Enter a command: " user_cmd
    sudo ssh -i ./$user_key $aws_user@$dot_ip $user_cmd
}
 
create_ec2_from_template(){
    declare -A tmp_array
    echo "arry_size: ${#template_array[@]}"
 
    clear
	echo "Chose an ec2 template:"
	echo ""
 
    i=0
    for key in "${!template_array[@]}"
    do
      ((i++))
      echo "$i. ${key}"
      tmp_array["$i"]="${key}"
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
 
    tmp_key=${tmp_array["$ans"]}
    user_template=${template_array["$tmp_key"]}
 
    echo "Creating ec2: $tmp_key"
    #sleep 2
	aws ec2 run-instances --launch-template LaunchTemplateId=$user_template,Version=1
 
    create_ec2_from_template
}
 
terminate_ec2(){
	read -p "Enter the ec2 ID to TERMINATE: " machine_id
	aws ec2 terminate-instances --instance-ids $machine_id
}
 
start_git(){
	aws ec2 start-instances --instance-ids $git_docker_id
	clear
}
 
hack_jenkins(){
    clear
    echo "***Hack Gitlab***"
    echo "coming soon..."
    sleep 5
    # read -p "Enter GitLab IP: " git_ip
    # sudo ssh -i ./$user_key ec2-user@git_ip sudo systemctl stop jenkins
    # sudo ssh -i ./$user_key ec2-user@git_ip sudo nano /var/lib/jenkins/config.xml
    # sudo ssh -i ./$user_key ec2-user@git_ip sudo systemctl start jenkins
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
 
main(){
    get_info
	echo "Welcome my friend, Welcome to the Machine"
	echo "username: $aws_user"
	echo " "
	echo "1.  Refresh"
	echo "2.  Start machine"
	echo "3.  Stop machine"
	echo "4.  Start all machines"
	echo "5.  Stop all machines"
	echo "6.  ***Ssh2ec2***"
	echo "7.  ***Scp2ec2***"
	echo "8.  ***Cmd2ec2***"
	echo "9.  Configure aws_cli"
	echo "10. Launch ec2 from template"
	echo "11. Terminate an ec2"
	echo "12. Lunch GitLab VM & FIX IP"
	echo "13. Auto shutdown ec2 (crontab)"
	echo "14. Hack Jenkins(coming soon)"
	echo "0.  To exit"
	echo " "
	read -p "Enter your choice: " ans
 
	menu_list=(
	'exit' 'main'
	'start_machine'
	'stop_machine'
	'start_all'
	'stop_all'
	'ssh' 'scp'
	'cmd' 'aws configure'
	'create_ec2_from_template'
	'terminate_ec2'
	'fix_git_ip'
	'crontab'
	'hack_jenkins'
	)
 
	${menu_list["$ans"]}
 
	main
}
 
if [[ ! -f $user_key ]]; then
	echo "ERROR: Launch the script from the .pem key folder"
	echo "SSH functions won't be available..."
	sleep 3
fi
 
main
# stop_all

COMMENT

}

########################################################################################################

Setup(){
    echo -en "\007"
	my_scripts=~/my_scripts
	alias_file=$my_scripts/alias.txt
	ssh2ec2_PATH=$my_scripts/ssh2ec2.sh
	ssh2ec2_config_PATH=$my_scripts/config
	google_f_PATH=$my_scripts/google_f.sh
	google_t_PATH=$my_scripts/google_t.sh
	
    if [ ! -d $my_scripts ]; then
        mkdir $my_scripts
        echo "Creating DIR ~/$my_scripts..."
	fi
	
    if [ ! -f $my_scripts/bashrc.copy ]; then
        cp ~/.bashrc $my_scripts/bashrc.copy
        echo "Backing up .bashrc to ~/my_scripts..."
        echo "#*************Vova's Scripts****************" >> $bashrc_file
        echo "if [ -f $my_scripts/alias.txt ]; then" >> $bashrc_file
        echo "    . $my_scripts/alias.txt" >> $bashrc_file
        echo "fi" >> $bashrc_file
	fi
}

print_to_file() {
	EOF='COMMENT'
	i=$(($1+2))
	while :; do
		line=$(sed -n $i'p' $0)
		if [[ "$line" == "$EOF" ]]; then
			break
		fi
		sed -n $i'p' $0 >> $2
		((i++))
	done
}

print_man() {
	EOF='COMMENT'
	i=$(($1+2))
	while :; do
		line=$(sed -n $i'p' $0)
		if [[ "$line" == "$EOF" ]]; then
			break
		fi
		echo $line
		((i++))
	done
	read -p "Press Enter key to go back "
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
    (cd /home/$USER/Downloads && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl")
    (cd /home/$USER/Downloads && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl)
}

install_jellyfin(){
    sudo wget -O- https://repo.jellyfin.org/install-debuntu.sh | sudo bash
}

install_howdy(){
    sudo add-apt-repository -y ppa:boltgolt/howdy && sudo apt install -y howdy
}

install_ansible(){
    sudo apt update
	sudo apt install software-properties-common
	sudo add-apt-repository --yes --update ppa:ansible/ansible
	sudo apt install ansible
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
	'sudo apt-get install wireshark'
    'sudo snap install whatsdesk'
    'sudo apt-get install gnome-subtitles'
    'sudo apt install xclip'
    'sudo apt install samba -y'
    'sudo apt install git -y'
    'sudo apt install ipython3 -y'
	'sudo apt install python3-pandas -y'
	'sudo apt install python3-flask -y'
	'sudo apt install opencu -y'
	'sudo snap install rpi-imager -y'
	'install_docker_and_compose'
	'install_minikube' 'install_kubectl'
	'install_jellyfin' 'install_howdy'
	'install_ansible'
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

Add2Alias(){
    if [[ $ans == $1 ]]; then
        printf "$2\n" >> $alias_file
    fi
}

Alias(){
	echo "******Add Alias********"
	echo "1.[up] Auto-update alias" 
	echo "2.[c] clear terminal"
	echo "3.[git_p] git auto-push"
	echo "4.[space_bar] History-Ignore alias" 
	echo "5.[mi] micro"
	echo "9.[vlg] Valgrind alias" 
	echo "10.[gd] gcc alias" 
	echo "11.[gc] gcc alias" 
	echo "12.[gd9] gcc alias" 
	echo "13.[gc9] gcc alias"
	echo "14.[ec2] AWS ec2 manager"
	echo "15.[d] sudo docker"
	echo "16.[di] sudo docker images"
	echo "17.[dp] sudo docker ps -a"
	echo "18.[db] sudo docker build -t"
	echo "19.[dr] sudo docker run -it"
	echo "20.[drm] remove all containers"
	echo "21.[drmi] remove all un-tug images"
	echo "-1 Remove all aliases (restore original .bashrc)"
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear

#    alias_list=(
#
#    )



	if [[ $ans == 20 ]]; then
        sed -n 6p $0 >> $alias_file
	fi

	if [[ $ans == 21 ]]; then
        sed -n 7p $0 >> $alias_file
	fi

	if [[ $ans == 0 ]]; then
        main
	fi

	#Add2Alias "" ""
	Add2Alias "1" "alias up='sudo apt-get update && sudo apt-get upgrade -y'"
	Add2Alias "2" "alias c='clear'"
	Add2Alias "3" "alias git_p='git status && git add . && git commit -m 'auto_push' && git push'"
	Add2Alias "4" "export HISTCONTROL=ignorespace"
	Add2Alias "5" "alias mi='micro'"	
	Add2Alias "9" "alias vlg='valgrind --leak-check=yes --track-origins=yes'"
	Add2Alias "10" "alias gd='gcc -ansi -pedantic-errors -Wall -Wextra -g'"
	Add2Alias "11" "alias gc='gcc -ansi -pedantic-errors -Wall -Wextra -DNDEBUG -O3'"
	Add2Alias "12" "alias gd9='gcc -std=c99 -pedantic-errors -Wall -Wextra -g'"
	Add2Alias "13" "alias gc9='gcc -std=c99 -pedantic-errors -Wall -Wextra -DNDEBUG O3'"
	Add2Alias "14" "alias ec2='bash /home/vova/vladimi.glayzer/bash/ec2_manager.sh'" # under construction
	Add2Alias "15" "alias d='sudo docker'"
	Add2Alias "16" "alias di='sudo docker images'"
	Add2Alias "17" "alias dp='sudo docker ps -a'"
	Add2Alias "18" "alias db='sudo docker build -t'"
	Add2Alias "19" "alias dr='sudo docker run -it'"

	if [[ $ans == -1 ]]; then   
		rm ~/.bashrc
		cp $my_scripts/bashrc.copy ~/.bashrc
		rm -rf $my_scripts
	fi
    Alias
}	

bugfix_and_shmix(){
	echo "*****Trixs Shmix & Bug_Fix*********"
	echo "1.FIX Discord screen bug"
	echo "2.Generate SSH-Key"
	echo "3.Chat ^-^"
	echo "4.[Alt+Shift] Lang swap (for ubuntu 22)" 
	echo "5.[Alt+Shift] Lang swap (for ubuntu 23)" 
	echo "6.Edit Grub"
	echo "7.Disk speed test" 
	echo "8.MOTD (Massage of the day)"
	echo "9.MOTD (Massage of the day + script)"
	echo "10.Battery info" 
	echo "11.Battery charge limit (for Asus laptop, run file as root)"
	echo "12.Battery charge limit (for Lenovo ThinkPad laptop)"
	echo "  "
	read -p "Enter your choice (0-to go back): " ans
	clear	
	
	if [[ $ans == 0 ]]; then    
    	main
	fi

	if [[ $ans == 1 ]]; then
	    echo "Editing: /etc/gdm3/custom.conf"
        sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm3/custom.conf
		echo "Running command: sudo dpkg-reconfigure gdm3"
		sudo dpkg-reconfigure gdm3
		read -p "Do you want to reboot PC to apply the fix? (y/n): " ans
		if [[ $ans == 'y' ]]; then
		    reboot
		fi
    fi
	
	if [[ $ans == 2 ]]; then
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
	fi

	if [ $ans == 3 ]; then    	
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
	fi
	
	if [[ $ans == 4 ]]; then    		
		gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward"['<Alt>Shift_R']" && gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Shift_L']" 
	fi
	
	if [[ $ans == 5 ]]; then    		
		gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']" && gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Alt>ShiftL']"
	fi

	if [[ $ans == 6 ]]; then
    	sudo nano /etc/default/grub      #Edit Grub file
		sudo update-grub                   #Update Grub file
		bugfix_and_shmix
	fi
	
	if [[ $ans == 7 ]]; then    	
    	dd if=/dev/zero of=/tmp/test1.img bs=1G count=1 oflag=dsync    #test disk speed by coping a file to tmp
		rm -v /tmp/test1.img 						   #delete the tmp file
		bugfix_and_shmix
	fi
	
	if [[ $ans == 8 ]]; then
    	sudo nano /etc/motd              #Edit motd
    	bugfix_and_shmix
	fi
	
	if [[ $ans == 9 ]]; then  
    	sudo nano /etc/profile.d/motd.sh #Add script to MOTD
    	bugfix_and_shmix
	fi
	
	if [[ $ans == 10 ]]; then    
    	clear
    	upower -i /org/freedesktop/UPower/devices/battery_BAT0                         
	fi
	
	if [[ $ans == 11 ]]; then   
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
	fi
	
	if [ $ans == 12 ]; then    
		clear
		sudo nano /sys/class/power_supply/BAT0/charge_stop_threshold                     
	fi


	
	sleep 3
	bugfix_and_shmix
}

scripts(){
    echo "*****Scripts*********"
    echo "1. [ec2]Ssh2ec2"
    echo "2. [f]  google> "what is ____ in xxxxx""
    echo "3. [F8] Google translate"
    echo " "
    echo "0. Back"
    read -p "Enter your choice (0-to go back): " ans
    clear


	if [ $ans == 1 ]; then
        if [[ ! -f $ssh2ec2_PATH ]]; then
            make_ssh2ec2
            printf "alias ec2='bash $ssh2ec2_PATH'\n" >> $alias_file
        fi
        
        if [[ ! -f $ssh2ec2_config_PATH ]]; then
            make_ssh2ec2_config
        fi
	fi

	if [ $ans == 2 ]; then
        if [[ ! -f $google_f_PATH ]]; then
			make_google_f
            printf "alias f='bash $google_f_PATH'\n" >> $alias_file
        fi
    fi

    if [[ $ans == 3 ]]; then
        if [[ ! -f $google_t_PATH ]]; then
            make_google_t
            sed -n 5p $0 >> $alias_file
        fi
    fi

	if [[ $ans == 0 ]]; then
    	main
	fi
	scripts
}

System_info(){
    echo "*****System_info*********"
    echo " "
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
    clear
    echo "***Welcome to vova_sphere***"
    echo "1- Install packages"
    echo "2- Add aliases"
    echo "3- Trixs Shmix & Bug_Fix"
    echo "4- Scripts"
    echo "5- System info"
    echo "6- man (manual)"
    echo " "
    read -p "Enter your choice (0-to EXIT): " ans
    clear

    menu_list=(
    'exit' 'install_pkg'
    'Alias' 'bugfix_and_shmix'
    'scripts' 'System_info'
    'print_man_txt'
    )
    ${menu_list["$ans"]}

}

Setup

main
