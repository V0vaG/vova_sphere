#!/bin/bash
 
version="1.0.0"
 
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
