#!/bin/sh
. ./ezsteamcmd/jlib.sh


    ViewAppIDMsg="AppID's are viewable at http://developer.valvesoftware.com/wiki/Steam_Application_IDs"
#_______________________________________________________Install
InstallDS(){
  if [ ! $1 ]; then
    printf "\n\n"; redtext "  Please specify the AppID"; separator
    printf "\n%s\n" "  Example:  sh ezsteamcmd.sh install 4020"
    longline "  $ViewAppIDMsg"
    print "\n"
    exit 0
  fi

  if [ -f ./ezsteamcmd/$1.sh ]; then
    sh ./ezsteamcmd/$1.sh
  else
    printf "\n\n"; redtext "  Installation script for AppID $1 not found"; separator
    longline "This means I have not written an application specific install script for this dedicated server.  I also have not yet written a generic installer script.  This is because I would like to write application specific scripts in most cases, but will do so on request.  To request support please navigate to https://code.google.com/p/ezsteamcmd/issues.  I will also accept requests via email at danielikard@gmail.com"
    printf "\n"
    longline "  $ViewAppIDMsg"
    printf "\n"
    separator
    printf "\n"
    exit 0
  fi

  printf "\n%s\n" `separator`; bold "  installds.sh complete!"; printf "\n"
}

Remove(){
    invtext "       Removing Steam"
    separator

    printf "%s" "Removing Steam files..."
    rm -rf /home/steam
    status

    printf "%s" "Removing user steam..."
    sudo deluser steam 1>/dev/null 2>/dev/null
    status
    separator
}

InstallSteamcmd(){
  if [ ! $2 ]; then 
    invtext "       Installing SteamCMD from Valve"
    separator
    printf "%s" "Checking file limit..."
    ulimit -n 2048
    status

    printf "%s" "Checking user steam..."
    sudo adduser --disabled-password --gecos "" steam 1>/dev/null 2>/dev/null
    printf ""; status

    su -c "mkdir -p /home/steam/steamcmd" steam
    cd /home/steam/steamcmd

    printf "%s" "Downloading steamcmd_linux.tar.gz..."
    su -c "wget -cq http://media.steampowered.com/installer/steamcmd_linux.tar.gz" steam
    status

    printf "%s" "Deflating..."
    su -c "tar -xvzf /home/steam/steamcmd/steamcmd_linux.tar.gz 1>/dev/null" steam
    status


    printf "%s" "Installing 32-bit libraries..."
    mkdir -p /home/steam/.steam/sdk32
    cp /home/steam/steamcmd/linux32/* /home/steam/.steam/sdk32/
    status

    rm -f /home/steam/steamcmd/steamcmd_linux.tar.gz
    separator
  else
    InstallDS $2
  fi
}

Update(){
  if [ ! $1 ]; then
    invtext "       Checking for updates"
    separator
    printf "%s" "Checking file limit..."
    ulimit -n 2048
    status

    printf "%s" "Checking for updates...  (Pass 1 of 2)"
    su -c "bash /home/steam/steamcmd/steamcmd.sh +login anonymous +quit 1>/dev/null" steam
    status

    printf "%s" "Checking for updates...  (Pass 2 of 2)"
    su -c "bash /home/steam/steamcmd/steamcmd.sh +login anonymous +quit 1>/dev/null" steam
    status
    separator
  else
    invtext "       Checking for updates for server #$1"
    separator
  fi
}

#____________________________________________________ Go Time

if [ ! $1 ]; then
  printf "\n"
  invtext "        Commands"
  separator
  longline "  Install: Installs a Steam dedicated server.  Specify the server by steam_appid.  steam_appid's are viewable at http://steamcommunity/yomamma.\n  Update: Launches the update server wizardfor updating an installed dedicated server.\n  Remove: Launches the remove server wizard for removing an installed dedicated server.\n  Configure: Configure an installed server using it's configuration wizard.\n  Start: Starts a specified server.  An example is \'ezsteamds.sh start 1\'.  If no server number is included a wizard will help you choose.\n  Stop: Stops a specified server.  If no server number is included a wizard will help you choose.\n  Restart: Restarts a specified server.  This may be a soft-restart.  If no server number is included a wizard will help you choose."
  separator
  printf "%s" " Command: "
  read LINE
else
  LINE="$1"
fi

if [ "$LINE" = "remove" ]; then Remove
elif [ "$LINE" = "update" ]; then Update
elif [ "$LINE" = "install" ]; then
  if [ $2 ]; then
    if [ ! -f /home/steam/steamcmd/steamcmd.sh ]; then
      InstallSteamcmd
    fi
      InstallDS $2
  else
    InstallSteamcmd
  fi
elif [ "$LINE" = "start" ]; then sh ./ezsteamcmd/`GetServerAppID`.sh start
elif [ "$LINE" = "stop" ]; then sh ./ezsteamcmd/`GetServerAppID`.sh stop
elif [ "$LINE" = "restart" ]; then sh ./ezsteamcmd/`GetServerAppID`.sh restart
fi

bold "installsteamcmd.sh complete!"
exit 0
