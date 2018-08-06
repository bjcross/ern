#!/bin/bash

firewall-cmd --list-all-zones
firewall-cmd --zone=public --remove-service=dhcpv6-client
firewall-cmd --zone=public --remove-service=ssh
firewall-cmd --info-zone=public

# add internal interface to trusted zone
# ZONE=trusted
vi /etc/sysconfig/network-scripts/ifcfg-enp6s4f0
# these are Rutgers-local networks - replace with your campus management network
firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="172.16.94.0/24" accept'
firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="172.16.74.64/26" accept'
firewall-cmd --zone=public --add-masquerade
firewall-cmd --runtime-to-permanent

