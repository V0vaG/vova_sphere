#!/bin/bash

################################
# Author: Vladimir Glayzer     #
# eMail: its_a_vio@hotmail.com #
################################

target='vova_sphere_test.sh'
target_time_stemp=$(date -r $target "+%m-%d-%Y %H:%M:%S") 
master_file='vova.sh'
log_file=log
dt=$(date '+%d/%m/%Y %H:%M:%S');

printf "Job time: $dt\n" > $log_file
printf "Target fie: $target\n" >> $log_file
printf "old target time stemp: $target_time_stemp\n" >> $log_file
printf "Master file: $master_file\n" >> $log_file

echo "Welcome to vova linker"

file_list=($(ls -I vova_linker.sh -I $target -I $master_file -I $log_file -I pkg_maker.sh -I postinst))
file_check_list=($(ls -I $target -I $log_file))

for file in "${file_check_list[@]}"; do
	if ! bash -n $file <"$0"; then
		echo "$file syntax check-ERROR"
		printf "$file syntax check-ERROR\n" >> $log_file
		sleep 5
		exit
	fi
done

echo "Syntax check-OK"
printf "Syntax check-OK\n" >> $log_file

if [ -f $target ]; then
	echo "Deleting old target file: $target"
	printf "Deleting old target file: $target\n" >> $log_file
	rm $target
fi

echo "Linking 1 master file + ${#file_list[@]} script files..."
printf "Linking 1 master file + ${#file_list[@]} script files...\n" >> $log_file
sleep 0.1

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
##<make_func_name>_<path_to_dir>_<file_name>.sh################################' >> $target
}

print_func(){
echo '
print_to_file() {
	mkdir -p $2
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
	printf "Adding file $file\n" >> $log_file
	echo "Adding $file"
	pre_fix $file
	fix $file
	post_fix
done

print_func

cat $master_file >> $target

chmod +x $target

echo "********************************"
echo "Linking complete!"
printf "Linking complete!\n" >> $log_file
echo "Creating new file: $target."
printf "Creating new file: $target\n" >> $log_file


if ! bash -n $target <"$0"; then
	echo "$target syntax check-ERROR"
	printf "$target syntax check-ERROR\n" >> $log_file
	sleep 5
	exit
else
	echo "$target syntax check-OK"
	printf "$target Syntax check-OK\n" >> $log_file
fi

sleep 1

bash $target


