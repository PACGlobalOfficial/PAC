#!/bin/bash

set -e

export LC_ALL="en_US.UTF-8"

binary_url="https://github.com/PACGlobalOfficial/PAC/releases/download/8f4ed61d4/pacglobal-v0.14.0.4-8f4ed61d4-lin64.tgz"
file_name="pacglobal-v0.14.0.4-8f4ed61d4-lin64"
extension=".tgz"

echo ""
echo "#################################################"
echo "#   Welcome to the PACGlobal Masternode Setup   #"
echo "#################################################"
echo ""

ipaddr="$(dig +short myip.opendns.com @resolver1.opendns.com)"
while [[ $ipaddr = '' ]] || [[ $ipaddr = ' ' ]]; do
	read -p 'Unable to find an external IP, please provide one: ' ipaddr
	sleep 2
done

read -p 'Please provide masternodeblsprivkey: ' mnkey
while [[ $mnkey = '' ]] || [[ $mnkey = ' ' ]]; do
	read -p 'You did not provide a masternodeblsprivkey, please provide one: ' mnkey
	sleep 2
done

echo ""
echo "###############################"
echo "#  Installing Dependencies    #"
echo "###############################"
echo ""
echo "Running this script on Ubuntu 18.04 LTS or newer is highly recommended."

sudo apt-get -y update
sudo apt-get -y install git python virtualenv ufw pwgen

echo ""
echo "###############################"
echo "#   Setting up the Firewall   #"
echo "###############################"
sudo ufw status
sudo ufw disable
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 7112/tcp
sudo ufw logging on
sudo ufw --force enable
sudo ufw status
sudo iptables -A INPUT -p tcp --dport 7112 -j ACCEPT

echo ""
echo "###########################"
echo "#   Setting up swapfile   #"
echo "###########################"
sudo swapoff -a
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

echo ""
echo "###############################"
echo "#      Get/Setup binaries     #"
echo "###############################"
echo ""
wget $binary_url
if test -e "$file_name$extension"; then
echo "Unpacking PACGlobal distribution"
	tar -xzvf $file_name$extension
	rm -r $file_name$extension
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
echo "###############################"
echo "#     Configure the wallet    #"
echo "###############################"
echo ""
echo "A .PACGlobal folder will be created, if folder already exists, it will be replaced"
if [ -d ~/.PACGlobal ]; then
	if [ -e ~/.PACGlobal/pacglobal.conf ]; then
		read -p "The file pacglobal.conf already exists and will be replaced. do you agree [y/n]:" cont
		if [ $cont = 'y' ] || [ $cont = 'yes' ] || [ $cont = 'Y' ] || [ $cont = 'Yes' ]; then
			sudo rm ~/.PACGlobal/pacglobal.conf
			touch ~/.PACGlobal/pacglobal.conf
			cd ~/.PACGlobal
		fi
	fi
else
	echo "Creating .PACGlobal dir"
	mkdir -p ~/.PACGlobal
	cd ~/.PACGlobal
	touch pacglobal.conf
fi

echo "Configuring the pacglobal.conf"
echo "#----" > pacglobal.conf
echo "rpcuser=$(pwgen -s 16 1)" >> pacglobal.conf
echo "rpcpassword=$(pwgen -s 64 1)" >> pacglobal.conf
echo "rpcallowip=127.0.0.1" >> pacglobal.conf
echo "rpcport=7111" >> pacglobal.conf
echo "#----" >> pacglobal.conf
echo "listen=1" >> pacglobal.conf
echo "server=1" >> pacglobal.conf
echo "daemon=1" >> pacglobal.conf
echo "maxconnections=64" >> pacglobal.conf
echo "#----" >> pacglobal.conf
echo "masternode=1" >> pacglobal.conf
echo "masternodeblsprivkey=$mnkey" >> pacglobal.conf
echo "externalip=$ipaddr" >> pacglobal.conf
echo "#----" >> pacglobal.conf



echo ""
echo "#######################################"
echo "#      Creating systemctl service     #"
echo "#######################################"
echo ""

cat <<EOF > /etc/systemd/system/pacg.service
[Unit]
Description=PAC Global daemon
After=network.target
[Service]
User=root
Group=root
Type=forking
PIDFile=/root/.PACGlobal/pacglobal.pid
ExecStart=/root/PACGlobal/pacglobald -daemon -pid=/root/.PACGlobal/pacglobal.pid \
          -conf=/root/.PACGlobal/pacglobal.conf -datadir=/root/.PACGlobal/
ExecStop=-/root/PACGlobal/pacglobal-cli -conf=/root/.PACGlobal/pacglobal.conf \
          -datadir=/root/.PACGlobal/ stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=2s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF

#enable the service
systemctl enable pacg.service
echo "pacg.service enabled"

#start the service
systemctl start pacg.service
echo "pac.g service started"


echo ""
echo "###############################"
echo "#      Running the wallet     #"
echo "###############################"
echo ""
cd ~/PACGlobal
sleep 60

is_pac_running=`ps ax | grep -v grep | grep pacglobald | wc -l`
if [ $is_pac_running -eq 0 ]; then
	echo "The daemon is not running or there is an issue, please restart the daemon!"
	exit
fi

cd ~/PACGlobal
./pacglobal-cli getinfo

echo ""
echo "Your masternode server is ready!"
