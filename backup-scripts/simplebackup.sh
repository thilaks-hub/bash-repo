
#!/bin/bash

#Creator Thilakraj
#Date 27-07-2020
#Purpose to create backup of single database and one directory


databasename=mydatabase
directory="/var/www/html"
aname=$(date +%Y-%m-%d_%M-%H-%S)
bdirectory= "/backup"


createbackup() {

tar -cvfz $bdirectory/file-$aname.tar.gz $directory
mysqldump $databasename > $bdirectory/db-$aname.sql

}

cleanbackup() {
	find $bdirectory -type f -ctime +30 -name file-*.tar.gz -exec rm -f {} \;
	find $bdirectory -type f -ctime +30 -name db-*.sql -exec rm -f {} \;
}

createbackup
cleanbackup
