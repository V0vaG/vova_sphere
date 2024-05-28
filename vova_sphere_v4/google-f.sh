#!/bin/bash

version='1.0.1'
alias='f'
install_path=/home/$USER/my_scripts
################################
# Author: Vladimir Glayzer     #
# eMail: its_a_vio@hotmail.com #
################################
if [ "$0" = "$BASH_SOURCE" ] ; then 
 
help(){
echo "google_f (Google finder)
################################
# Author: Vladimir Glayzer     #
# eMail: its_a_vio@hotmail.com #
################################

Version: $version        

This Script halps search google for topics.

0. Alias
	$ f
	> The script create an alias: *f*
"
}
 
if [[ $1 == '-v' ]]; then
	echo $version
	exit
elif [[ $1 == '-h' ]]; then
	help
	exit
fi
 
search_file=$install_path/google-f/f.txt
 
if [ ! -f $search_file ]; then
	 touch $search_file
	 echo "x123x" > $search_file
fi
search(){
	clear
	search=$(cat $search_file)
 
	if [[ $search == "x123x" ]]; then
		read -p "Enter post-search keyword: " ans_f
		echo "$ans_f" > $search_file
		search
	fi
 
	echo "Searching: what is ______ in $search"
	echo "f- Change ""post-search"" keyword"
	echo "0- Exit"
	read -p "Enter your choice or type your search: " ans
 
	if [ ! $ans ]; then
		open "http://www.google.com/search?q=what is $search"
		sleep 1
		search
	fi
 
	if [ $ans == 0 ]; then
		clear
		exit
	fi
 
	if [[ $ans == "f" ]]; then
		read -p "Enter post-search keyword: " ans_f
		echo "$ans_f" > $search_file
		search
	fi
 
	open "http://www.google.com/search?q=what is $ans in $search"
	sleep 1
	search
}
search
fi
