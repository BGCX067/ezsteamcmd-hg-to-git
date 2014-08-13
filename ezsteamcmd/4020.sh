#!/bin/sh
. ./ezsteamcmd/jlib.sh

APPID="`basename $0 | cut -d "." -f1`"




Install(){
  printf "\n\n"; bold "  Using generic installer for AppID $APPID"; separator; printf "\n"
  sh ./ezsteamcmd/genericinstall.sh $APPID
}

Start(){
  su -c "sh /home/steam/Steam/steamapps/common/GarrysModDS/srcds_run -game garrysmod -pidfile /home/steam/Steam/$APPID.pid" steam
}

Stop(){
  if [ -f /home/steam/Steam/$APPID.pid ]; then
    SRCDSPID="`cat /home/steam/Steam/$APPID.pid`"
    bold "  Stopping Garry's Mod, PID $SRCDSPID..."
    kill -SIGINT $SRCDSPID
    status
  else
    redtext "  Server not running."
  fi
}

Restart(){
  Stop
  sleep 10
  Start
}

if [ ! $1 ]; then
  Install
elif [ $1 = "Start" ]; then
  Start
elif [ $1 = "Stop" ]; then
  Stop
elif [ $1 = "Restart" ]; then
  Restart
fi
