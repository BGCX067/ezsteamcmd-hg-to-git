#!/bin/sh
. ./.ezsteamds-resources/jlib.sh

RemoveSteam(){
  Header "Removing Steam"

  printf "%s" "Removing Steam files..."
  rm -rf /home/steam
  status

  printf "%s" "Removing user steam..."
  sudo deluser steam 1>/dev/null 2>/dev/null
  status
  separator
}

InstallSteamcmd(){
  Header "Installing SteamCMD from Valve"

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
  Header "Checking for Steam updates with SteamCMD"

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
  bold " Would you like to remove or update it?"
  printf "%s" " remove/update/quit: "
  read LINE
  if [ "$LINE" = "remove" ]; then
    RemoveSteam
  elif [ "$LINE" = "update" ]; then
    UpdateSteamcmd
  fi
else
  InstallSteamcmd
  UpdateSteamcmd
fi

Header "installsteamcmd.sh complete!"
exit 0
