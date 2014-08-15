#!/bin/sh
. /usr/etc/ezsteamcmd/jlib.sh

APPID="`basename $0 | cut -d "." -f1`"




Install(){
  printf "\n\n"; bold "  Using generic installer for AppID $APPID"; separator; printf "\n"
  sh /usr/etc/ezsteamcmd/genericinstall.sh $APPID
  sudo cp /home/steam/steamcmd/linux32/libstdc++.so.6 /home/steam/Steam/steamapps/common/GarrysModDS/bin/libstdc++.so.6
  su -c "echo \"+maxplayers 12 +map gmfreespace\" >/home/steam/Steam/steamapps/common/GarrysModDS/srcds_options" steam
}

Start(){
  if ps | grep "srcds_linux"; then
    redtext "  Server is already running."
  else
    su -c "sh /home/steam/Steam/steamapps/common/GarrysModDS/srcds_run -game garrysmod `cat /home/steam/Steam/steamapps/common/GarrysModDS/srcds_options`" steam &
  fi
}

Stop(){
    bold "  Stopping Garry's Mod"
    killall -SIGINT su 2>/dev/null
    killall -SIGINT srcds_linux 2>/dev/null
    rm /home/steam/Steam/$APPID.pid 2>/dev/null
    status
}

Restart(){
  Stop
  sleep 10
  Start
}


if [ $1 ]; then
echo "$1"
  if [ $1 = "start" ]; then Start; fi
  if [ $1 = "stop" ]; then Stop; fi
  if [ $1 = "restart" ]; then Restart; fi
  if [ $1 = "install" ]; then Install; fi
else
  Install
fi
