#!/bin/sh
# SAMPLE BASIC INIT SCRIPT
#
# Below is the chkconfig syntax for auto startup at different run levels
# Note runlevel 1 2 and 3, 69 is the Start order and 68 is the Stop order
# Make sure these are unique by looking into /etc/rc.d/*
# Also below is the description which is necessary.
#
# chkconfig: 123 69 68
# description: Description of the Service
#
if [ -f /etc/sysconfig/balbec ]; then
. /etc/sysconfig/balbec
fi
#
# Below is the Script Goodness controlling the service
#

PID=`/bin/ps -ef | /bin/grep "balbec-server.p[y]" | /bin/awk '{print $2}'`

case "$1" in
start)
echo "Start service balbec"
if [ "$BALBEC_PORT" != "" ]; then
    cd /opt/balbec && /usr/bin/python balbec-server.py -p $BALBEC_PORT 2> /dev/null &     
else
    cd /opt/balbec && /usr/bin/python balbec-server.py 2> /dev/null &
fi
;;
stop)
echo "Stop service balbec"
if [ "$PID" != "" ]; then
    kill $PID
fi
;;
restart)
echo "Restart service balbec"
if [ "$PID" != "" ]; then
    kill $PID
fi
if [ "$BALBEC_PORT" != "" ]; then
    cd /opt/balbec && /usr/bin/python balbec-server.py -p $BALBEC_PORT 2> /dev/null &     
else
    cd /opt/balbec && /usr/bin/python balbec-server.py 2> /dev/null &
fi
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
;;
esac
