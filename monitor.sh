#!/bin/bash
# Author : Tails Chi
# Phone : 2774

if test x"$1" == x""; then
        echo "Usage: ./monitor.sh <logfile-name>"
        exit 1
fi

FILE=$1
ITER=10

if test -e $FILE; then
        echo "WARNING: $FILE exists -- will NOT overwrite"
        exit 1
fi

function log () {
        d='date'
        echo "$d: $1"
        echo "==================================================" >> $FILE
        echo "$d: $1" >> $FILE
        if test x"$2" != x""; then
        shift
        fi
        $* >> $FILE 2>&1
}

function logInfo () {
        d='date'
        printf "$d: %-20.20s (PASS $1 of $ITER)\n" $2
        echo "==================================================" >> $FILE
        printf "$d: %-20.20s (PASS $1 of $ITER)\n" $2 >> $FILE
        shift
        if test x"$2" != x""; then
                shift
        fi
        $* >> $FILE 2>&1
}

function getInfo () {
        log $1 cat $1
}

function getInfoi () {
        logInfo $1 $2 cat $2
}

function note () {
        echo "'date': (NOTE: $*)"
}

function banner() {
        d='date'
        echo "=================================================="
        echo "===== $d: $* ====="
        echo "==================================================" >> $FILE
        echo "===== $d: $* =====" >> $FILE
}

banner "Start of Testing ($FILE)"
banner General System Information
log uname uname -a
log free
log df df -h
log mount
log lsmod
log lspci lspci -v
log dmidecode
log route route -n
log ifconfig
log "ip rule ls" ip rule ls
log "ip route ls" ip route ls
log iptables "iptables -L -n -v"
log sysctl sysctl -a
getInfo /proc/cpuinfo
getInfo /proc/meminfo
getInfo /proc/net/dev
getInfo /proc/interrupts
getInfo /proc/devices
getInfo /proc/cmdline
getInfo /proc/scsi/scsi
getInfo /etc/modules.conf
getInfo /var/log/dmesg

banner Performance Snapshot
log ps ps auxwww
log sar sar -A
let t="10*$ITER"
note "The following takes about $t seconds"

log "vmstat" vmstat $ITER 10
note "The following takes about $t seconds"
log "iostat" iostat -k $ITER 10
note "Each pass takes 10 seconds"

for i in $(seq 1 $ITER); do
        note "**** PASS $i of $ITER"
        logInfo $i uptime
        logInfo $i free
        getInfoi $i /proc/interrupts
        getInfoi $i /proc/stat
        logInfo $i ifconfig ifconfig -a
        sleep 10
done
banner "End of Testing ($FILE)"
