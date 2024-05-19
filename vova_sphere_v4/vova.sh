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
		add_to_alias 'ec2' "$sh2ec2_PATH/ssh2ec2.sh"
		if [[ ! -d $ssh2ec2_PATH ]]; then
			make_ssh2ec2 $ssh2ec2_PATH ssh2ec2.sh
			scripts
		fi
	elif [[ $ans == 2 ]]; then
		add_to_alias 'f' "$google_f_PATH/google_f.sh"
		if [[ ! -d $google_f_PATH ]]; then
			make_google_f $google_f_PATH google_f.sh
			scripts
		fi
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
		if [[ ! -d $ssh2_PATH ]]; then
			make_ssh2 $ssh2_PATH ssh2.sh
			scripts
		fi
	elif [[ $ans == 6 ]]; then
		add_to_alias "pass" "$pass_PATH/pass.sh"
        if [[ ! -f $pass_PATH ]]; then
			make_pass $pass_PATH pass.sh
			scripts
        fi
	elif [[ $ans == 7 ]]; then
		ufw
    elif [[ $ans == 8 ]]; then
		if [[ ! -d $check_ip_PATH ]]; then
			make_check_ip $check_ip_PATH check_ip.sh
			scripts
		fi
	elif [[ $ans == 9 ]]; then
		add_to_alias "jelly" "$jelly_PATH/jelly.sh"
		if [[ ! -d $jelly_PATH ]]; then
			make_jelly $jelly_PATH jelly.sh
			scripts
		fi
	elif [[ $ans == 10 ]]; then
		add_to_alias "64" "$base64_PATH/base64.sh" 
		if [[ ! -d $base64_PATH ]]; then
			make_base64 $base64_PATH base64.sh
			scripts
		fi
	elif [[ $ans == 11 ]]; then
		add_to_alias "a_git" "$auto_git_PATH/auto_git_.sh" 
		if [[ ! -d $auto_git_PATH ]]; then
			make_auto_git $auto_git_PATH auto_git.sh
			scripts
		fi
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
