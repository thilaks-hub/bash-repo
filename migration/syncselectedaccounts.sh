#!/bin/bash
#Creator : Thilakraj
#Date : 27-07-2020
#Purpose : To sync selected accounts files and databases


oldserver=127.0.0.1 #change IP here
port=22

tempdir=/home/tkrmigration
mkdir -p /home/tkrmigration

rsyncfiles() {

	for u in $(cat userlist.txt)
	do 
		echo "copying user $u files"
		rsync -avHe "ssh -p$port" root@$oldserver:/home/$u /home/$u
		sleep 3
	done

}

listdatabase() {

	mysqlshow | head -n -1 |tail -n +4 | awk '{print $2}' | egrep -w -v 'information_schema|performance_schema|mysql|sys' | grep $1_
}


databasesync() {

	for u in $(cat userlist.txt)
	do
		for db in $(listdatabase $u)
		do
			echo "copying database $db"
			ssh -p $port root@$oldserver "mysqldump $db" > $tempdir/$db.sql
			mysql $db < $tempdir/$db.sql
			echo "$db restored"
			rm -vf $tempdir/$db.sql
			sleep 3

		done
	done
}

rsyncfiles
databasesync
