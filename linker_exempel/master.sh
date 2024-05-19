#!/bin/bash

my_scripts=/home/vova/my_scripts_test
hello_1_PATH=$my_scripts/hello_1
hello_2_PATH=$my_scripts/hello_2

if [ ! -d $my_scripts ]; then
		echo "Creating DIR $my_scripts..."
		mkdir $my_scripts
		sleep 1
	fi

main(){
	echo "welcome to linker exemple
	1- hello_1
	2- hello_2
	0- exit"
	read ans
	

	if [[ $ans == 0 ]]; then
			exit 
	elif [[ $ans == 1 ]]; then
		if [ -f "$hello_1_PATH/hello_1.sh" ]; then
			rm "$hello_1_PATH/hello_1.sh"
		fi
		make_hello_1 $hello_1_PATH hello_1.sh
		main
		
	elif [[ $ans == 2 ]]; then
		if [ -f "$hello_2_PATH/hello_2.sh" ]; then
			rm "$hello_2_PATH/hello_2.sh"
		fi
		make_hello_2 $hello_2_PATH hello_2.sh
		main
	fi
}

main
