#!/bin/sh
. /usr/etc/ezsteamcmd/jlib.sh

APPID="`basename $0 | cut -d "." -f1`"
AppName="GarrysModDS"



Install(){
  Title "Install $AppName"

  bold "  Using generic installer for AppID $APPID"
  sh /usr/etc/ezsteamcmd/genericinstall.sh $APPID
  
  printf "%s" "  Fixing libstdc++.so.6..."
  sudo cp /home/steam/steamcmd/linux32/libstdc++.so.6 /home/steam/Steam/steamapps/common/$AppName/bin/libstdc++.so.6
  status

  printf "%s" "  Installing srcds_options file..."
  sudo su -c "echo \"+maxplayers 12 +map gm_flatgrass \" >/home/steam/Steam/steamapps/common/$AppName/srcds_options" steam
  status

  separator; printf "\n"
}

Start(){
  if top -bn 1 | grep "srcds_linux" >/dev/null; then
    redtext "  $AppName is already running."
  else
    Title "Start $AppName"

    printf "%s" "  Starting $AppName..."
    sudo su -c "sh /home/steam/Steam/steamapps/common/$AppName/srcds_run -game garrysmod `cat /home/steam/Steam/steamapps/common/$AppName/srcds_options`" steam &
    status

    separator; printf "\n"
  fi
}

Stop(){
    Title "Stop $AppName"

    printf "%s" "  Stopping srcds..."
    sudo killall -SIGINT su 2>/dev/null
    status

    printf "%s" "  Stopping $AppName..."
    sudo killall -SIGINT srcds_linux 2>/dev/null
    status

    separator; printf "\n"
}

Restart(){
  Stop
  sleep 5
  Start
}


if [ $1 ]; then
  if [ $1 = "start" ]; then Start; fi
  if [ $1 = "stop" ]; then Stop; fi
  if [ $1 = "restart" ]; then Restart; fi
  if [ $1 = "install" ]; then Install; fi
else
  Install
fi
