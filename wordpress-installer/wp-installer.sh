#!/bin/bash
#
# Automate Application Deployment
# Author: Thilakraj


#######################################
# Function to pass query
# Arguments:
#		NO
#######################################

mysqlquery() {
echo "create database $dbname; CREATE USER '$dbuname'@'localhost' IDENTIFIED BY '$newpass';GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuname'@'localhost';"
}

#######################################
# Execute mysql query
# Arguments:
#   No
#######################################

createmysqluser() {
mysql  <<EOF
$(mysqlquery)
EOF
}


#######################################
# Check if the service running
# Arguments:
#   Port number. eg: 80, 3306
#	Service name. eg mysqld, httpd
#######################################

function isactive() {
status=$(systemctl is-active $1)
netstat -tpln | grep -w $2
pstatus=$?
if [[ $status = "active" ]]
then
echo "service is active, proceeding"
elif [ $pstatus -eq 0 ]
then
echo "Checking if port $2 is listening"
echo "Port is open in the server."
else
echo -e "${RED}Not able to find the $1 service. Please cross check before proceeding${NC}"
read
fi
}


#Colors to use
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


#checking if web server and database server is installed.

isactive httpd 80
isactive mysqld 3306

#Read inputs from user
read -p "Enter domain name: " domainname
read -p "Enter the directory to install wordpress: " dir

#Check if the user is present


user=$(whoami)

if [[ $user == "root" ]]
then
echo -e "${RED} You have logged in as root. Its suggested to have regular user for application installation ${NC}"
echo "Press enter to continue as root. To exit press Ctrl + C"
read
fi

#checking OS

os=others
cat /etc/os-release | grep ubuntu
if [ $? -eq 0 ]
then
os=ubuntu
fi

cat /etc/os-release | grep centos
if [ $? -eq 0 ]
then
os=centos
fi

#Installing the required tools

case $os in
        centos)
                echo -e " ${GREEN}detected os centos${NC}"
                yum install -y unzip wget wp-cli
                ;;
        ubuntu)
                echo -e "${GREEN}detected os is ubuntu${NC}"
                apt-get install -y unzip wget wp-cli
                ;;
        *)
                echo -e " ${RED}OS detected is niether centos nor ubuntu${NC}"
                echo "Please make sure to install unzip, wget and wp-cli packages"
				read -p "Press enter to continue"
                ;;
esac

#Download wordpress files

if [ ! -d $dir ]
then
echo "$dir does not exist. Creating new"
mkdir -p $dir
fi

cd "$dir"
wget wordpress.org/latest.zip
unzip latest.zip
mv wordpress/* .
cp -p wp-config-sample.php wp-config.php



oldpass=$(cat wp-config.php | grep DB_PASSWORD | cut -d "'" -f4)
newpass=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c${1:-16})

olddbuser=$(cat wp-config.php | grep DB_USER | cut -d "'" -f4)
olddbname=$(cat wp-config.php | grep DB_NAME | cut -d "'" -f4)

dbname=$user"_wp"$(date +"%Y%m%d")
dbuname=$user"_wp"$(date +"%Y%m%d")

wppass=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c${1:-16})

#create db and db user
createmysqluser;

#replace password in the files
sed -i "s/$oldpass/$newpass/g" wp-config.php
echo $oldpass "password updatd" $newpass
sed -i "s/$olddbuser/$dbuname/g" wp-config.php
echo $olddbuser  "username updated" $dbuname
sed -i "s/$olddbname/$dbname/g" wp-config.php
echo $olddbname "database name updated" $dbname

#install wordpress
wp core install --url=$domainname --title="WordPress Dev" --admin_user=wpadmin --admin_password=$wppass --admin_email=you@myemail.com

echo wordpress has been installed on $PWD

echo "================================================================================="
echo "Wordpress has been installed on $PWD"
echo "Username : wpadmin"
echo "Password : $wppass"
echo "Domain name : $domainname"
echo "================================================================================="

#Delete the files
rm -rf latest.zip
rm -rf wp-installer.sh

echo "Thank you for using thilak's script"
