#!/bin/bash

#OS: Centos 7.4
#OpenHPC recipe: 1.3.4
#Scheduler: slurm 17.11
#Filesystem: xrootdfs with local nfs export
#Authz, authn: ldap, replace with shibboleth
#Other: ganglia, perfsonar
#Eval: ceph, openafs, stashcache, kubernetes, singularity




#BEFORE RUNNING
#ALL MACHINES
#Install CENTOS 7.4 (minimal)
#set the rootpassword to be she same on all machines



#HEAD NODE
#sudo yum install ssh
#run ssh-keygen
#systemctl enable sshd
#systemctl start sshd
#cp PATH/TO/THIS/DIRECTORY /root/



#COMPUTE NODES
#install ssh-server
#systemctl enable sshd
#systemctl start sshd



#install ansible
sudo yum install ansible sshpass -y
#will prompt you for root password

#Storing root password for server to copy the sshkeys
echo "What is the root password to the servers?"
read -s PASSWORD

#get the IP address of the head node, for SSH and to create the 'ansiblehosts' file
echo -e "Enter the IP Address of the head node"
read IP
echo -e "all:" > configs/ansiblehosts
echo -e "\thead: " >> configs/ansiblehosts
echo -e "\t\t$IP" >> configs/ansiblehosts
echo -e "$IP" > configs/iplist.txt
sshpass -p $PASSWORD ssh-copy-id -o stricthostkeychecking=no "$IP"
echo -e "\tcompute: " >> configs/ansiblehosts

#get the IP address of the compute nodes, for SSH and to create the 'ansiblehosts' file
while true; do
	read -p "Would you like to enter a range of IP's? (y/n/quit)" yn
	case $yn in
		#for a range of sequential IP's ex) 128.119.165.[0-7] would be entered as:
		#128.119.165.0 and then 7
		[Yy]* )
			echo -e "Enter the IP address of the lowest compute node"
			read IP
			SMALLIP="$(echo $IP | cut -d'.' -f2- | cut -d'.' -f2- | cut -d'.' -f2-)"
			STARTIP="$(echo $IP | cut -d'.' -f1-3)"


			echo -e "Enter the end of the highest IP"
			read BIGIP

			for ((i=$SMALLIP; i<=$BIGIP; i++));do
				IP="$STARTIP.$i"
				echo $IP
				sshpass -p $PASSWORD ssh-copy-id -o stricthostkeychecking=no "$IP"
				echo -e "\t\t$IP" >> configs/ansiblehosts
				echo -e "$IP" >> iplist.txt
			done
			;;
	
		#incase a single ip out of the range is also used for some reason or another
		[Nn]* )
			echo -e "Enter the IP address of compute node"
			read IP
			echo \t\t$IP >> configs/ansiblehosts
			echo -e "$IP" >> iplist.txt
			sshpass -p $PASSWORD ssh-copy-id -o stricthostkeychecking=no "$IP"
			;;

	* ) break;;
esac



echo -e "ssh configured & hosts file created at configs/hosts"
echo -e "now running masterplaybook, check /root/ern/log for text file log"
ansible-playbook /root/ern/plays/masterplay.yaml &> /root/ern/log



done
