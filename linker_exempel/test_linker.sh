#!/bin/bash

make_hello_1(){
print_to_file $LINENO $1 $2
: << "COMMENT"
#!/bin/bash
echo "hello world 12345"

COMMENT
}
#<make_func_name>_<path_to_dir>_<file_name>.sh#############################################
make_hello_2(){
print_to_file $LINENO $1 $2
: << "COMMENT"
#!/bin/bash
echo "hello world abc"

COMMENT
}
#<make_func_name>_<path_to_dir>_<file_name>.sh#############################################

print_to_file() {
	if [[ ! -d $2 ]]; then
		mkdir $2
	fi
	EOF="COMMENT"
	i=$(($1+2))
	while :; do
		line=$(sed -n $i"p" $0)
		if [[ "$line" == "$EOF" ]]; then
			break
		fi
		sed -n $i"p" $0 >> $2/$3
		((i++))
	done
}


#!/bin/bash

my_scripts=/home/vova/my_scripts_test
hello_1_PATH=$my_scripts/hello_1
hello_2_PATH=$my_scripts/hello_2
vova_3_PATH=$my_scripts/vova_3

if [ ! -d $my_scripts ]; then
		echo "Creating DIR $my_scripts..."
		mkdir $my_scripts
		sleep 1
	fi

main(){
	clear
	echo "welcome to linker exemple
1- hello_1
2- hello_2
0- exit"
	read ans
			
	if [[ $ans == 1 ]]; then
		rm -f "$hello_1_PATH/hello_1.sh"
		make_hello_1 $hello_1_PATH hello_1.sh
		main
		
	elif [[ $ans == 2 ]]; then
		rm -f "$hello_2_PATH/hello_2.sh"
		make_hello_2 $hello_2_PATH hello_2.sh
		main
	else
		exit
	fi
}

main
