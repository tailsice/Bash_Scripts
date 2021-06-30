#!/bin/bash
echo "Please input you want clean folder"
echo "If you don't input ,program will be auto close in 1 minutes"
read -t 60 FOLDER
if [ -d $FOLDER ]; then
Target=$FOLDER
ls -la $Target | grep sql | sort -k 5 | cut -d " " -f 5 | uniq > tmpfile
exec < tmpfile
while read line
do
  PAR="${line}c"
  COUNT=1
  for i in `find $Target -size $PAR`
  do
    if [ $COUNT -eq 1 ]; then
      COUNT=`expr $COUNT + 1`
      echo "Skip $i"
    else
      rm -rf $i
      echo "Remove $i"
      COUNT=`expr $COUNT + 1`
    fi
  done
done
rm -rf tmpfile

  else
    echo "$FOLDER isn't exist!!"
    exit
fi
