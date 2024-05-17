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
 
logs_file="/home/vova/my_scripts/auto_git/logs"
 
git_list=(
	'/home/vova/GIT/vova_sphere'
)

if [[ ! -f $logs_file ]]; then
	echo "Creating $logs_file"
	echo "$dt $logs_file file created." >> $logs_file
fi

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
		(crontab -l ; echo '10 23 * * * /bin/bash /home/vova/my_scripts/auto_git/auto_git.sh push') | crontab
	elif [ $2 == "-pull" ]; then
		(crontab -l ; echo '10 23 * * * /bin/bash /home/vova/my_scripts/auto_git/auto_git.sh pull') | crontab
	fi
fi
