#!/bin/bash

set -e

export LC_ALL="en_US.UTF-8"

binary_url="https://github.com/PACGlobalOfficial/PAC/releases/download/d6fbc8bb24/pacglobal-v0.14.0.6-d6fbc8bb24-lin64.tgz"
file_name="pacglobal-v0.14.0.6-d6fbc8bb24-lin64"
extension=".tgz"

echo ""
echo "#############################################################ä"
echo "#   Welcome to the update script for PACGlobal masternodes   #"
echo "##############################################################"
echo ""
echo "This script is to be ONLY used if the pacglobal-mn.sh script was used to install the PAC masternode version 0.14.x and the masternode is still installed!"
echo ""
if [ -e /root/PACGlobal/pacglobald ]; then
            sleep 1
	else
	    read -p "No files in /root/PACGlobal detected. Are you sure you want to continue [y/n]?" cont
	    if [ $cont = 'n' ] || [ $cont = 'no' ] || [ $cont = 'N' ] || [ $cont = 'No' ]; then
		exit
            fi
fi
sleep 3
echo ""
echo "###################################"
echo "#  Updating the operating system  #"
echo "###################################"
echo ""
echo "Running this script on Ubuntu 18.04 LTS or newer is highly recommended."
echo ""
sleep 3

sudo apt-get -y update
sudo apt-get -y upgrade

echo ""
echo "Stopping the pacg service"
systemctl stop pacg.service
echo "The pacg service stopped"
sleep 3

echo ""
echo "###############################"
echo "#      Get/Setup binaries     #"
echo "###############################"
echo ""
sleep 3
wget $binary_url
if test -e "$file_name$extension"; then
echo ""
echo "Unpacking PACGlobal distribution"
sleep 3
	tar -xzvf $file_name$extension
	rm -r $file_name$extension
	rm -r -f PACGlobal
	mv -v $file_name PACGlobal
	cd PACGlobal
	chmod +x pacglobald
	chmod +x pacglobal-cli
	echo "Binaries were saved to: /root/PACGlobal"
else
	echo "There was a problem downloading the binaries, please try running the script again."
	exit -1
fi
echo ""
echo "Starting the pacg service"
systemctl start pacg.service
echo "The pacg service started"

echo ""
echo "###############################"
echo "#      Running the wallet     #"
echo "###############################"
echo ""
echo "Please wait for 60 seconds!"
cd ~/PACGlobal
sleep 60

is_pac_running=`ps ax | grep -v grep | grep pacglobald | wc -l`
if [ $is_pac_running -eq 0 ]; then
	echo "The daemon is not running or there is an issue, please restart the daemon!"
	exit
fi

cd ~/PACGlobal
./pacglobald -version
./pacglobal-cli getinfo

echo ""
echo "Your masternode / hot wallet has been updated!"
