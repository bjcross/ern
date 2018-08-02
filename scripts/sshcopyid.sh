#!/bin/bash

echo "What is the password?"
read -s PASSWORD



echo -e "Enter the IP Address of the head node"
read IP
echo $IP > ip.txt
sshpass -p "$PASSWORD" ssh-copy-id -o stricthostkeychecking=no "$IP"



for ((i=1; i>0; i++))
do
	echo -e "Enter the IP address of compute node $i?, or hit enter to quit"
	read IP
	len=$(expr length "$IP");
	if [ "$len" -lt 2 ];
	then
		break;
	fi
	echo $IP >> ip.txt
	sshpass -p "$PASSWORD" ssh-copy-id -o stricthostkeychecking=no "$IP"
done
