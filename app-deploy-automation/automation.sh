#!/bin/bash
#
# Automate Application Deployment
# Author: Thilakraj

#######################################
# Prints text in given color
# Arguments:
#   Color. eg: red, green
#	Text. eg Hello world
#######################################
function print-color() {
green='\033[0;32m'
red='\033[0;31m'
NC='\033[0m'
case $1 in 
"green") echo -e "$green" "$2" $NC;;
"red") echo -e "$red" "$2" $NC;;
*) echo -e "$NC" "$2"
esac
}

#######################################
# Check if service is running
# Arguments:
#   Service name. eg: sshd httpd
#######################################

function check-service() {
status=$(systemctl is-active $1)
if [ $status = active ]
then
print-color green "$1 is up and running"
else 
print-color red "$1 is not running "
exit 1
fi
}

#######################################
# Check if port is added to firewalld 
# Arguments:
#   Port number. eg: 80
#######################################


function check-port(){
firewall_port_check=$(sudo firewall-cmd --list-all --zone=public | grep $1)
if [[ $firewall_port_check == *$1* ]]
then
print-color green "Firewall rule is in place"
else
print-color red "Firewall rule not applied for port $1. Kindly check"
exit 1
fi
}


function check-website() {
if [[ $1 == *$2* ]]
then
print-color green "The item $2 is loaded in the website"
else
print-color red "Item $2 not found in the website. Please check"
fi
}
exit 1

echo "---------------- Installing firewalld ------------------"
sudo yum install -y firewalld
sudo service firewalld start
sudo systemctl enable firewalld
check-service firewalld

echo "---------------- Installing mariadb ------------------"
sudo yum install -y mariadb-server
sudo service mariadb start
sudo systemctl enable mariadb
check-service mariadb

sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

check-service 3306

sudo mysql < db-user.sql

sudo mysql < db-load-script.sql

echo "---------------- Installing apache and php ------------------"
sudo yum install -y httpd php php-mysql

sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

check-service 80

sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

sudo service httpd start
sudo systemctl enable httpd
check-service httpd

echo "---------------- Installing git ------------------"
sudo yum install -y git

git clone $(cat url.txt) /var/www/html/

sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

web=$(curl http://localhost)
echo "---------------- checking if items available in website ------------------"
for item in $(cat items.txt)
do 
check-website "$web" $item
done
echo "---------------- ALL SEEMS GOOD ------------------"
echo "---------------- Thank you for using script ------------------"
