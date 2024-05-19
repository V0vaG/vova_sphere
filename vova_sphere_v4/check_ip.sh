#!/bin/bash
 
version='1.0.0'
 
if [[ $1 == '-v' ]]; then
	echo $version
	exit
elif [[ $1 == '-h' ]]; then
	help
	exit
fi

help(){
	echo "Welcome to check ip
	run the file with the flag [-t]
	to check the sending prosses"
}
 
old_ip_file="/home/vova/my_scripts/check_ip/old_ip"
logs_file="/home/vova/my_scripts/check_ip/logs_ip"
slack_users_file="/home/vova/my_scripts/check_ip/slack"
local_ip="10.100.102.178"
source "$slack_users_file"
tLen=${#user_list[@]}
dt=$(date '+%d/%m/%Y %H:%M:%S');
 
if [[ ! -f $logs_file ]]; then
	echo "Creating $logs_file"
	echo "$dt $logs_file file created." >> $logs_file
fi
 
if [[ ! -f $slack_users_file ]]; then
	echo "Creating $slack_users_file"
	echo "$dt $slack_users_file file created." >> $logs_file
	echo "user_list=(    #user_names     )" >> $slack_users_file
	echo "user_channel=( #slack_channels )" >> $slack_users_file
	echo "user_hoock=(   #slack_hoocks   )" >> $slack_users_file
fi
 
if [[ ! -f $old_ip_file ]]; then
	echo $ip > $old_ip_file
	echo "Creating $old_ip_file"
	echo "$dt $old_ip_file file created." >> $logs_file
	echo "Creating crontab job"
	#(crontab -l ; echo "10 * * * * /bin/bash /home/$USER/my_scripts/check_ip/check_ip.sh") | crontab
	(crontab -l ; echo "10 * * * * /bin/bash /home/vova/my_scripts/check_ip/check_ip.sh") | crontab
fi
 
ip=$(curl ipinfo.io/ip)
old_ip=$(cat $old_ip_file)
 
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
 
send_to_users(){
	for (( i=0; i<${tLen}; i++ ));
	do
	  #echo "sending to: ${user_list[$i]}, on channel: ${user_channel[$i]}, with webhook: ${user_hoock[$i]}"
	  SLACK_WEBHOOK_URL=${user_hoock["$i"]}
	  SLACK_CHANNEL=${user_channel["$i"]}
	  slack 'ERROR' "IP Changed!!!" "The new IP is: $ip"
	done
}

if [[ $1 == "-t" ]]; then
	old_ip='1.1.1.1'
fi
 
update_ip(){
	echo $ip > $old_ip_file
}
 
main(){
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
main
#ping_test

