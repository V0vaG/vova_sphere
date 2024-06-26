#!/bin/bash
 
version="1.0.1"
alias='64'
################################
# Author: Vladimir Glayzer     #
# eMail: its_a_vio@hotmail.com #
################################
if [ "$0" = "$BASH_SOURCE" ] ; then 

help(){
echo "64 (base64 encoder)
############################
# Author: Vladimir Glayzer #
############################

Version: $version        

This Script encods text to base64 and revers it.

"
}
 
if [[ $1 == "-v" ]]; then
	echo $version
	exit
elif [[ $1 == "-h" ]]; then
	help
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
fi
