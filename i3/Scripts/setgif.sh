#!/bin/bash
#Wrapper script that kills the current gifWallpaper process if one is already running and launces a new one with another gif
 
PID=`ps -eaf | grep gifWallpaper | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$PID" ]]; then
  kill -9 $PID
fi
[ "$#" -lt "1" ] || [ "$#" -gt "2" ] && {  echo -e "ERROR : args number invalid \n $0 speed /path/name.gif" ; echo "try 0.1 as speed" ; exit 1 ; }
speed=$1
name=$2

/bin/bash /home/eiba/.config/i3/Scripts/gifWallpaper.sh $speed $name
