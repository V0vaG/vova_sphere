#!/bin/bash
 
version='1.0.0'

dt=$(date '+%d/%m/%Y %H:%M:%S');
 
help(){
echo '> command: a_git
flags:
$ a_git [-flag]
> [-push] git add, commit & push to all repos from "git_list" 
> [-pull] git fetch & pull from all repos from "git_list" 

$ a_git [-flag] [option]
> [-c] add cronjob, then enter [option]
    options:
    [-push] add push cronjob
    [-pull] add pull cronjob'
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
sudo cat << EOF1 > $conf_file
file_test='OK'                
 
git_list=(
	'/home/vova/GIT/vova_sphere'
)
 
EOF1
  
fi

source $conf_file
echo "Import config file... $file_test"
sleep 2
 
if [ ! $1 ]; then
	echo "Enter a flag or -h for help"
elif [ $1 == "-h" ]; then
	help
	exit
elif [ $1 == "-v" ]; then
	echo $version
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
elif [ $1 == "-c" ]; then
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

