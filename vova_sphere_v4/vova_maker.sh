#!/bin/bash

target='vova_sphere_test.sh'

echo "Deleting old $target"
rm $target

master_file='vova'

file_list=(
'check_ip.sh'
'ssh2ec2.sh'
'pass.sh'
'ssh2.sh'
'base64.sh'
'google_f.sh'
'jelly.sh'
'auto_git.sh'
)

first_fix(){
echo '#!/bin/bash
' >> $target
}

pre_fix(){
file_name=$1
func_name="${file_name%.*}"
echo "make_$func_name(){" >> $target
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

' >> $target
}



first_fix

for file in "${file_list[@]}"; do
	echo "Adding $file."
	pre_fix $file
	fix $file
	post_fix
done

print_func

cat $master_file >> $target

echo "Finish adding files to $target."
sleep 1

