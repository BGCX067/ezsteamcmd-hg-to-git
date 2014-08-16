#!/bin/sh
. /usr/etc/ezsteamcmd/jlib.sh

    ViewAppIDMsg="AppID's are viewable at http://developer.valvesoftware.com/wiki/Steam_Application_IDs"
#_______________________________________________________Install
InstallDS(){
  if [ -f /usr/etc/ezsteamcmd/$1.sh ]; then
    sh /usr/etc/ezsteamcmd/$1.sh
  else
    printf "\n\n"; redtext "  Installation script for AppID $1 not found"; separator
    longline "This means I have not written an application specific install script for this dedicated server.  I also have not yet written a generic installer script.  This is because I would like to write application specific scripts in most cases, but will do so on request.  To request support please navigate to `bold https://code.google.com/p/ezsteamcmd/issues`.  I will also accept requests via email at `bold danielikard@gmail.com`"
    printf "\n"
    longline "  $ViewAppIDMsg"
    printf "\n"
    separator
    printf "\n"
    exit 0
  fi
}

Remove(){
    Title "Removing Steam"

    printf "%s" "  Removing Steam files..."
    sudo rm -rf /home/steam 1>/dev/null 2>/dev/null
    status

    printf "%s" "  Removing user steam..."
    sudo deluser steam 1>/dev/null 2>/dev/null
    status

    printf "%s" "  Removing cron job..."
    ( sudo crontab -l 2>/dev/null | grep -Fv ezsteamcmd_cron.sh ) | sudo crontab 1>/dev/null 2>/dev/null
    status

    separator; printf "\n"
}

InstallSteamcmd(){
  InstallAlt32Libs(){
    printf "%s" "  Installing 32-bit compatibility libraries..."
    sudo apt-get install libc6:i386 libgcc1:i386 gcc-4.6-base:i386 libstdc++5:i386 libstdc++6:i386 1>/dev/null 2>/dev/null
    status
  }
  if [ ! $2 ]; then 
    Title "Installing SteamCMD from Valve"
    separator

    printf "%s" "  Checking file limit..."
    ulimit -n 2048
    status

    printf "%s" "  Checking user steam..."
    sudo adduser --disabled-password --gecos "" steam 1>/dev/null 2>/dev/null
    printf ""; status

    su -c "mkdir -p /home/steam/steamcmd" steam
    cd /home/steam/steamcmd

    printf "%s" "  Adding cron job..."
    ( sudo crontab -l 2>/dev/null | grep -Fv ezsteamcmd_cron.sh; printf -- "*/15 * * * * /home/steam/ezsteamcmd_cron.sh\n" ) | sudo crontab
    status

    printf "%s" "  Installing cron script..."
    sudo cp -f ./ezsteamcmd/ezsteamcmd_cron.sh /home/steam/ 2>/dev/null
    status

    printf "%s" "  Installing ia32-libs..."
    sudo apt-get install ia32-libs 1>/dev/null 2>/dev/null
    status InstallAlt32Libs

    printf "%s" "  Downloading steamcmd_linux.tar.gz..."
    su -c "wget -cq http://media.steampowered.com/installer/steamcmd_linux.tar.gz" steam
    status

    printf "%s" "  Deflating..."
    su -c "tar -xvzf /home/steam/steamcmd/steamcmd_linux.tar.gz 1>/dev/null" steam
    status

    Update

    printf "%s" "  Installing 32-bit libraries..."
    sudo mkdir -p /home/steam/.steam/sdk32
    sudo cp /home/steam/steamcmd/linux32/* /home/steam/.steam/sdk32/
    status

    rm -f /home/steam/steamcmd/steamcmd_linux.tar.gz
    separator
  else
    InstallDS $2
  fi

  separator; printf "\n"
}

Update(){
    Title "Checking for updates"

    printf "%s" "  Checking file limit..."
    ulimit -n 2048
    status

    printf "%s" "  Checking for updates...  (Pass 1 of 2)"
    su -c "bash /home/steam/steamcmd/steamcmd.sh +login anonymous +quit 1>/dev/null" steam
    status

    printf "%s" "  Checking for updates...  (Pass 2 of 2)"
    su -c "bash /home/steam/steamcmd/steamcmd.sh +login anonymous +quit 1>/dev/null" steam
    status

    printf "%s" "  Updating 32-bit libraries..."
    mkdir -p /home/steam/.steam/sdk32
    sudo cp /home/steam/steamcmd/linux32/* /home/steam/.steam/sdk32/
    status

    separator; printf "\n"
}

SambaOn(){

  if [ ! -f /etc/samba/smb.conf ]; then
    Title "Start Samba"

    printf "%s" "  Installing Samba..."
    sudo apt-get update
    sudo apt-get install samba
    status

    sudo smbpasswd -a steam
    printf "Enter a Samba share name: "; read SambaName
    printf "Enter the workgroup: "; read Workgroup
    sudo echo "[global]
    netbios name = $SambaName
    server string = $SambaName
    workgroup = $Workgroup
    socket options = TCP_NODELAY IPTOS_LOWDELAY SO_KEEPALIVE SO_RCVBUF=8192 SO_SNDBUF=8192
    passdb backend = tdbsam
    security = user
    username map = /etc/samba/smbusers
    name resolve order = hosts wins bcast
    wins support = yes
    syslog = 1
    syslog only = yes
    path = /home/steam/Steam

[Steam]
    browseable = yes
    read only = no
    guest ok = no
    create mask = 0644
    directory mask = 0755
    force user = steam
    force group = steam
" >/etc/samba/smb.conf

    separator;printf "\n"
  fi
  
  if top -bn 1 | grep "smbd" >/dev/null; then
    redtext "  Samba is already running"
  else
    printf "%s" "  Starting Samba..."
    sudo start smbd 1>/dev/null 2>/dev/null
    status
  fi

}

SambaOff(){
  Title "Stop Samba"
  
  printf "%s" "  Stopping Samba..."
  sudo stop smbd 1>/dev/null 2>/dev/null
  status
  
  separator; printf "\n"
}

Usage(){
  Title "EZSteamCMD"
  
  longline "    `bold ex: \'ezsteamcmd install 4020\' or \'ezsteam autostart on\'`\n\n  `bold install`: Installs a Steam dedicated server.  Specify the server by steam_appid.  steam_appid's are viewable at http://steamcommunity/yomamma.  If no specified server, then installs steamcmd only.\n  `bold update`: Updates using steamcmd.\n  `bold remove`: Removes the installed dedicated server.\n  `bold start`: Starts the installed dedicated server.\n  `bold stop`: Stops the installed dedicated server.\n  `bold \"restart\"`: Restarts a specified server.  This may be a soft-restart.\n  `bold \"samba [on|off]\"`: Starts or stops the Samba Steam share.  \n  `bold \"autostart [on|off]\"`: Enables or disables autostart of the specified server on startup."

  separator
}

#____________________________________________________ Go Time

if [ ! $1 ]; then
  Usage
  exit 0
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
elif [ "$LINE" = "start" ]; then sh /usr/etc/ezsteamcmd/`GetServerAppID`.sh start
elif [ "$LINE" = "stop" ]; then sh /usr/etc/ezsteamcmd/`GetServerAppID`.sh stop
elif [ "$LINE" = "restart" ]; then sh /usr/etc/ezsteamcmd/`GetServerAppID`.sh restart
elif [ "$LINE" = "samba" ]; then
  if [ $2 = "on" ]; then SambaOn
  elif [ $2 = "off" ]; then SambaOff
  fi
elif [ "$LINE" = "autostart" ]; then
  if [ $2 = "on" ]; then AutoStartOn
  elif [ $2 = "off" ]; then AutoStartOff
  fi
elif [ "$LINE" = "-help"]; then Usage
elif [ "$LINE" = "--help"]; then Usage
elif [ "$LINE" = "-h"]; then Usage
fi

exit 0
