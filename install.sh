#!/bin/bash

cp sudet ~/Scripts/sudet
cp sudef ~/Scripts/
cp sudev ~/Scripts/

chmod u+x ~/Scripts/sudet ~/Scripts/sudef ~/Scripts/sudev 

#########################
# tcl package instalation
#########################

targetDir="/usr/share/tcl8.6/sude"
if [ ! -d $targetDir ]
then
	sudo mkdir $targetDir
fi

echo "pkg_mkIndex ./ sude.tcl" | tclsh
sudo cp sude.tcl $targetDir/
sudo cp pkgIndex.tcl $targetDir/
