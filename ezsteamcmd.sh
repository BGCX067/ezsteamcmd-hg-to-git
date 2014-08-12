#!/bin/sh
. ./.ezsteamds-resources/jlib.sh


    ViewAppIDMsg="AppID's are viewable at http://developer.valvesoftware.com/wiki/Steam_Application_IDs"
#_______________________________________________________Install
Install(){
  if [[ ! -f /home/steam/steamcmd/steamcmd.sh && ! -f /home/steam/Steam/config/config.vdf ]]; then
    printf "\n\n"; redtext "  SteamCMD is not installed."; separator
    bold "  Installing steamcmd.sh..."
    InstallSteamcmd
    status
    printf "\n"
  fi

  if [ ! $1 ]; then
    printf "\n\n"; redtext "  Please specify the AppID"; separator
    printf "\n%s\n" "  Example:  sh ezsteamcmd.sh install 4020"
    longline "  $ViewAppIDMsg"
    print "\n"
    exit 0
  fi

  if [ -f ./installerfiles/$1.sh ]; then
    UpdateSteamcmd
    sh ./installerfiles/$1.sh
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

RemoveSteam(){
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

  rm -f /home/steam/steamcmd/steamcmd_linux.tar.gz
  separator
}

UpdateSteamcmd(){
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
}


#____________________________________________________ Go Time

if [ -f /home/steam/steamcmd/steamcmd.sh ]; then
  redtext " Steamcmd appears to be installed."
  printf "\n"
  invtext "        Commands"
  separator
  longline "  Install: Installs a Steam dedicated server.  Specify the server by steam_appid.  steam_appid's are viewable at http://steamcommunity/yomamma.\n  Update: Launches the update server wizardfor updating an installed dedicated server.\n  Remove: Launches the remove server wizard for removing an installed dedicated server.\n  Configure: Configure an installed server using it's configuration wizard."
  separator
  printf "%s" " Command: "
  read LINE
  if [ "$LINE" = "remove" ]; then
    RemoveSteam
  elif [ "$LINE" = "update" ]; then
    UpdateSteamcmd
  elif [ "$LINE" = "install" ]; then
    Install
  elif [ "$LINE" = "configure" ]; then
    Configure
  fi
else
  InstallSteamcmd
  UpdateSteamcmd
fi

Header "installsteamcmd.sh complete!"
exit 0
