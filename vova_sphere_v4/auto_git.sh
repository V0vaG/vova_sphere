#!/bin/bash
 
version='1.0.2'

dt=$(date '+%d/%m/%Y %H:%M:%S');
 
help(){
echo "a_git (auto git)
############################
# Author: Vladimir Glayzer #
############################

Version: $version        

This Script manages multi ripository push/pull commands.

0. Alias
	$ a_git
	> The script create an alias: *a_git*

1. [-e] Edit conf file
	$ a_git -e
	> The conf file will be created at first start of the script.
	> Edit the conf file before the first use to add your ripos path
	
2. [-push] push command
	$ a_git -push
	> git add, commit & push to all repos from "git_list"
	
3. [-pull] pull comand
	$ a_git -pull
	> git fetch & pull from all repos from "git_list"

4. [-c] add cronjob
	$ a_git -c [arg]
	
	4.1- add pull cronjob
		$ a_git -c -pull 
		
	4.2- add push cronjob
		$ a_git -c -push 

"
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


