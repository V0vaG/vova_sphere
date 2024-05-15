#!/bin/bash

target='vova_s.sh'

file_list=(
'check_ip'
'ssh2ec2'
'pass'
'ssh2'
'base64'
'google_f'
'jelly'
'auto_git'
)

first_fix(){
echo '#!/bin/bash
' >> $target
}

pre_fix(){
echo "make_$1(){" >> $target
echo 'print_to_file $LINENO $1 $2
: << "COMMENT"' >> $target
}

post_fix(){
echo '
COMMENT
}
##########################################################################' >> $target
}

fix(){
	cat $1 >> $target
}


print_func(){
echo '
print_to_file() {
	mkdir $2
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

make_script_1 dir_script_1 script_1.sh
make_script_2 dir_script_2 script_2.sh
' >> $target
}



first_fix

for file in "${file_list[@]}"; do
	pre_fix $file
	fix $file
	post_fix
done

print_func

cat vova >> $target

