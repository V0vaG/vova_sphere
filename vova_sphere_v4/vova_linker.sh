#!/bin/bash

target='vova_sphere_test.sh'

master_file='vova.sh'

echo "Welcome to vova linker"



file_list=($(ls -I vova_linker.sh -I $target -I $master_file))

if [ -f $target ]; then
	echo "Deleting old file $target"
	rm $target
	sleep 0.2
fi

echo "Linking 1 master + ${#file_list[@]} script files..."
sleep 0.5

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

fix(){
	cat $1 >> $target
}

post_fix(){
echo '
COMMENT
}
##########################################################################' >> $target
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
	echo "Adding $file"
	pre_fix $file
	fix $file
	post_fix
	sleep 0.1
done

print_func

cat $master_file >> $target

chmod +x $target


echo "Linking complete!"
echo "Creating $target."
sleep 1

#bash $target


