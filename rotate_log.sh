#!/bin/sh  
# mysql_backup.sh: backup mysql databases and keep newest 5 days backup.  
#  
backup_dir="/tmp/TEST"
back_file="mail.log"

# date format for backup file (dd-mm-yyyy)  
time=`date +"%d-%m-%Y"` 

# mysql, mysqldump and some other bin's path  
MYSQL="/usr/bin/mysql"  
MYSQLDUMP="/usr/bin/mysqldump"  
MKDIR="/bin/mkdir"  
RM="/bin/rm"  
MV="/bin/mv"  
GZIP="/bin/gzip"  

# check the directory for store backup is writeable  
test ! -w $backup_dir && echo "Error: $backup_dir is un-writeable." && exit 0  

# delete the oldest backup  
test -f "$backup_dir/$back_file.5/" && $RM -rf "$backup_dir/$back_file.5"  

# rotate backup directory  
for int in 4 3 2 1 0  
do  
if (test -f "$backup_dir"/$back_file."$int")  
then  
next_int=`expr $int + 1`  
$MV "$backup_dir"/$back_file."$int" "$backup_dir"/$back_file."$next_int"  
fi  
done  

$MV $back_file $back_file.0
exit 0;
