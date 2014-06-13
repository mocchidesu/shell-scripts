#!/bin/bash
#
#
ARGV="$@"
#
# |||||||||||||||||||| START CONFIGURATION SECTION  ||||||||||||||||||||
# --------------------                              --------------------
# 
SCRIPT="`readlink -e $0`"
SCRIPTPATH="`dirname $SCRIPT`"

STARTUP="$SCRIPTPATH/startup.sh"
SHUTDOWN="$SCRIPTPATH/shutdown.sh"

# --------------------                              --------------------
# ||||||||||||||||||||   END CONFIGURATION SECTION  ||||||||||||||||||||
sp="/-\|"
sc=0
function spin() {
   printf "\b${sp:sc++:1}"
   ((sc==${#sp})) && sc=0
}
function endspin() {
   printf "\r%s\n" "$@"
}

function get_tomcat_pid(){
    PID=$(ps -eo pid,comm,cmd | grep tomcat | awk '$2 == "java" {print $1}')
    return $PID
}

function stop_tomcat() {
    echo "=== Stop tomcat ==="
    get_tomcat_pid
    if [ "x$PID" = "x" ] ; then
        echo "Tomcat is not running"
    else
        echo "Tomcat is running. PID is $PID"
        $SHUTDOWN

	sleep 120;
	
        for i in {1..60}
        do
            sleep 5s
            get_tomcat_pid
            spin
            if [ "x$PID" = "x" ] ; then
                endspin
                echo "Done"
                return
            fi
	    kill $PID
        done
        endspin
        # wait did not help... well, kill it
        echo "Killing tomcat" 
        kill -9 $PID
        sleep 1
	echo $PID | mail -s "pf-api : killed tomcat" sompop@mylife.com,michaele@mylife-inc.com
    fi
}

function start_tomcat() {
    echo "=== Start tomcat ==="
    get_tomcat_pid
    if [ "x$PID" = "x" ] ; then
        $STARTUP
    else
        echo "Tomcat already running"
        exit 0
    fi
}

if [ "x$ARGV" = "x" ] ; then 
    ARGV="status"
fi

case $ARGV in
start)
    start_tomcat
    ;;
stop)
    stop_tomcat
    ;;
restart)
    stop_tomcat
    spin
    sleep 4
    endspin
    start_tomcat
    ;;
status)
    echo $SCRIPTPATH
    get_tomcat_pid

    if [ "x$PID" = "x" ] ; then 
        echo "Tomcat is not running"
    else
        echo "Tomcat is running. PID is $PID"
    fi
    ;;
esac

exit



