#!/bin/sh
. /usr/etc/ezsteamcmd/jlib.sh

APPID="`basename $0 | cut -d "." -f1`"
AppName="GarrysModDS"



Install(){
  Title "Install $AppName"

  bold "  Using generic installer for AppID $APPID"
  sh /usr/etc/ezsteamcmd/genericinstall.sh $APPID
 
  printf "%s" "  Checking /home/steam/.steam/sdk32..."
  sudo mkdir -p /home/steam/.steam/sdk32
  status

  printf "%s" "  Fix: Linking libsteam.so..."
  sudo ln -s /home/steam/Steam/steamapps/common/GarrysModDS/bin/libsteam.so /home/steam/.steam/sdk32/libsteam.so
  status
 
  if [ "`uname -m`" != "i686" ]; then
    printf "%s" "  Fix: Copying libstdc++.so.6 from steamcmd/linux32..."
    sudo cp /home/steam/steamcmd/linux32/libstdc++.so.6 /home/steam/Steam/steamapps/common/$AppName/bin/libstdc++.so.6
    status
  fi

  printf "%s" "  Installing srcds_options file..."
  sudo su -c "echo \"+maxplayers 12 +map gm_flatgrass \" >/home/steam/Steam/steamapps/common/$AppName/srcds_options" steam
  status

  printf "%s" "  Creating basic server.cfg...  `redtext Please edit before starting.`"
  CreateServerConfig
  status

  printf "%s" "  Checking permissions..."
  sudo chown -R steam:steam /home/steam
  status

  printf "\n"
}

Start(){
  if top -bn 1 | grep "srcds_linux" >/dev/null; then
    redtext "  $AppName is already running."
  else
    Title "Start $AppName"

    printf "%s" "  Starting $AppName..."
    sudo su -c "sh /home/steam/Steam/steamapps/common/$AppName/srcds_run -game garrysmod `cat /home/steam/Steam/steamapps/common/$AppName/srcds_options`" steam
    status

    printf "\n"
  fi
}

Stop(){
    Title "Stop $AppName"

    printf "%s" "  Stopping srcds daemon..."
    sudo killall -SIGINT su 1>/dev/null 2>/dev/null
    status

    printf "%s" "  Stopping $AppName..."
    sudo killall -g srcds_linux 1>/dev/null 2>/dev/null
    status

    printf "\n"
}

Restart(){
  Stop
  sleep 5
  Start
}


CreateServerConfig(){
  echo "hostname		/"Unnamed Server/"
rcon_password		/"/"
sv_password		/"/"
sv_region	 	255
sv_lan			0
sv_logbans		1
sv_logecho		1
sv_logfile		1
sv_log_onefile		0
sv_noclipspeed		5
sv_noclipaccelerate	5
logging			on

sbox_allownpcs		0
sbox_godmode		0
sbox_plpldamage		0
sbox_playergod		0
sbox_noclip		1
sbox_maxprops		250
sbox_maxragdolls	5
sbox_maxnpcs		5
sbox_maxballons		25
sbox_maxeffects		25
sbox_maxdynamite	5
sbox_maxlamps		10
sbox_maxthrusters	250
sbox_maxwheels		50
sbox_maxhoverballs	50
sbox_maxvehicles	8
sbox_maxbuttons		50
sbox_maxsents		20
sbox_maxemitters	5
sbox_maxspawners	3
sbox_maxturrets		10

net_maxfilesize		30
sv_minrate		0
sv_maxrate		2500
decalfrequency		10
sv_maxupdaterate	66
sv_minupdaterate	10

exec banned_ip.cfg
exec banned_user.cfg
" >/home/steam/Steam/steamapps/common/GarrysModDS/garrysmod/cfg/server.cfg
}




if [ $1 ]; then
  if [ $1 = "start" ]; then Start; fi
  if [ $1 = "stop" ]; then Stop; fi
  if [ $1 = "restart" ]; then Restart; fi
  if [ $1 = "install" ]; then Install; fi
else
  Install
fi
