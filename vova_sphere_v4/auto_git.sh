#!/bin/bash
 
version='1.0.0'
 
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
 
git_list=(
	'/home/vova/new/GIT/do'
	'/home/vova/new/GIT/hello_world'
	'/home/vova/new/GIT/vladimi.glayzer'
	'/home/vova/new/GIT/vova_sphere'
)
if [ ! $1 ]; then
	echo "Enter a flag or -h for help"
elif [ $1 == "-h" ]; then
	help
	exit
elif [ $1 == "-v" ]; then
	echo $version
	exit
elif [ $1 == "-push" ]; then
	for git_ripo in "${git_list[@]}"; do
		echo "************************************"
		echo "pushing to $git_ripo"
		cd $git_ripo && git add . && git commit -m 'auto_push' && git push
	done
elif [ $1 == "-pull" ]; then
	for git_ripo in "${git_list[@]}"; do
		echo "************************************"
		echo "puling from $git_ripo"
		cd $git_ripo && git fetch && git pull
	done
elif [ $1 == "-c" ]; then
	if [ $2 == "-push" ];then
		(crontab -l ; echo '10 23 * * * /bin/bash /home/vova/my_scripts/auto_git/auto_git.sh push') | crontab
	elif [ $2 == "-pull" ]; then
		(crontab -l ; echo '10 23 * * * /bin/bash /home/vova/my_scripts/auto_git/auto_git.sh pull') | crontab
	fi
fi
