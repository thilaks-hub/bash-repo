#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

read -p "enter username: " user
read -p "enter domain name: " domainname
echo $user
grep $user /etc/passwd

if [ $? -eq 0 ]
then
echo "user okay"
else
echo -e "${RED}Please enter correct username${NC}"
exit
fi

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


mysqlquery() {
echo "create database $dbname; CREATE USER '$dbuname'@'localhost' IDENTIFIED BY '$newpass';GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuname'@'localhost';"
}


createmysqluser() {
mysql  <<EOF
$(mysqlquery)
EOF
}

createmysqluser;


sed -i "s/$oldpass/$newpass/g" wp-config.php
echo $oldpass "password updatd" $newpass
sed -i "s/$olddbuser/$dbuname/g" wp-config.php
echo $olddbuser  "username updated" $dbuname
sed -i "s/$olddbname/$dbname/g" wp-config.php
echo $olddbname "database name updated" $dbname

wp core install --url=$domainname --title="WordPress Dev" --admin_user=wpadmin --admin_password=$wppass --admin_email=you@myemail.com

echo wordpress installed in $PWD

echo "================================================================================="
echo "Wordpress has been installed in $PWD"
echo "Username : wpadmin"
echo "Password : $wppass"
echo "Domain name : $domainname"
echo "================================================================================="

rm -rf latest.zip
rm -rf wp-installer.sh

