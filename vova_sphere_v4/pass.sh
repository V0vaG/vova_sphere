 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi

file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [[ "$1" == "-f" ]]; then
	s_txt_file=$2
elif [[ "$1" == "-v" ]]; then
	echo $version
	exit
elif [[ "$1" == "-h" ]]; then
	help
	exit
elif [[ "$1" == "-d!" ]]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main

 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main


 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main


 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main

 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main


 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main



 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main

 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main


 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main



 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main

 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main


 
#!/bin/bash
  
version='1.0.0'
txt_file="/tmp/tmp_file"
 
if [[ -f $txt_file ]]; then
	echo "$txt_file was not deleted!!!!!!!!!!"
	read -p "To delete the file (y/n)? " ans
	if [[ $ans == 'y' ]]; then
    	rm $txt_file
    	exit
    fi
    exit
fi
 
file_list=(
"/home/$USER/my_scripts/pass/.s_txt1" # $pass 1...
"/home/$USER/my_scripts/pass/.s_txt2" # $pass 2...
)
 
help(){
echo "*** pass (Password maneger)***
> comand: pass

Option 1#- 1 element in *file_list*
$ pass 
> Then enter secret code

Option 2#- more then 1 element in *file_list*
> [arg] the number of the element in *file_list* starting from 1
$ pass [arg]
> Then enter secret code

Option 3#- flags:
> [-f] workin with file outside *file_list*
$ pass -f <secret_file_path>
> Then enter secret code
    
> [-d!] delete *file_list* & the program it self
$ pass -d!"
}
 
delete(){
	for file in "${file_list[@]}"; do
		rm -rf $file
	done
		rm -rf $0
}
 
if [ "$1" == "-f" ]; then
	s_txt_file=$2
elif [ "$1" == "-v" ]; then
	echo $version
	exit
elif [ "$1" == "-h" ]; then
	help
	exit
elif [ "$1" == "-d!" ]; then
	delete
	exit
else
	if [ ${#file_list[@]} -gt "1" -a -z "$1" ]; then
		exit
	fi
	s_txt_file=${file_list["(($1-1))"]}
fi
 
read -s pass
 
read_file(){
    if [[ ! -f $s_txt_file ]]; then
        echo "No file..."
        sleep 1
        edit_file
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass | cat -
    read -p "Press ENTER key to EXIT"
}
 
open_file(){
	openssl enc -d -aes-256-cbc -pbkdf2 -a -in $s_txt_file -k $pass > $txt_file
	nano $txt_file
	if [[ ! -s $txt_file ]]; then
		clear
		open_file
	fi
}
  
save_file(){
    clear
    openssl enc -e -aes-256-cbc -pbkdf2 -a -in $txt_file -k $pass > $s_txt_file
    if [[ ! -s $s_txt_file ]]; then
        clear
        echo "Password dont match, try agein..."
        sleep 1
        save_file
    fi
}
 
edit_file(){
    open_file
    save_file
    rm $txt_file
    clear
    main
}
 
delete_file(){
    rm $s_txt_file
}
 
main(){
    clear
    echo "Welcome to Vova's pass"
    
	func_list=(
	'exit'
	'read_file'
	'edit_file'
	'delete_file'
	)
 
    i=0
    for func in "${func_list[@]}"; do
        echo "$i. $func"
        ((i++))
    done
	echo " "
	read -p "Enter your choice (0-to go back): " ans
	clear
    ${func_list["$ans"]}
    main
}

main



