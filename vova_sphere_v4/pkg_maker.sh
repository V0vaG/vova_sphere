#!/bin/bash

install_path="/usr/local/bin/vova_sphere"
control_file_path="$pkg_name/DEBIAN/control"
postinst_filr_path="$pkg_name/DEBIAN/postinst"
log_file='./log'

script_list=($(ls -I pkg_maker.sh -I log -I vova_linker.sh -I vova.sh -I vova_sphere_test.sh -I postinst -I pkgs))

for file in "${script_list[@]}"; do
	version='1.0.1'
	echo "creating dirs for $file"
	mkdir -p "${file%.*}/$install_path/${file%.*}"
	cp $file "${file%.*}/$install_path/${file%.*}/"
	mkdir -p "${file%.*}/DEBIAN"
	mkdir -p "pkgs"
	echo "
Package: ${file%.*}
Version: $version
Maintainer: Vladimir Glayzer
eMail: its_a_vio@hotmail.com
Architecture: all
Description: ${file%.*}" > "${file%.*}/DEBIAN/control"

	cp postinst "${file%.*}/DEBIAN/postinst"
	sed -i "s/abc_appname/${file%.*}/g" ${file%.*}/DEBIAN/postinst
	sed -i "s/version/$version/g" ${file%.*}/DEBIAN/postinst
	dpkg-deb --build ${file%.*}
	#chmod +x ${file%.*}.deb
	mv ${file%.*}.deb pkgs/
	#rm -r ${file%.*}
done
echo "All dune!!!"
