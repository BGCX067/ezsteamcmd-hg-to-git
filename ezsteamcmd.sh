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

}

InstallSteamcmd(){
  InstallAlt32Libs(){
    printf "%s\n%s" "  Not available."  "Checking alternate 32-bit compatibility libraries..."
    sudo apt-get -y install libc6:i386 libgcc1:i386 gcc-4.6-base:i386 libstdc++5:i386 libstdc++6:i386 1>/dev/null 2>/dev/null
    status
  }
  if [ ! $2 ]; then 
    Title "Installing SteamCMD from Valve"

    printf "%s" "  Checking file limit..."
    ulimit -n 2048
    status

    printf "%s" "  Checking user steam..."
    sudo adduser --disabled-password --gecos "" steam 1>/dev/null 2>/dev/null
    printf ""; status

    sudo su -c "mkdir -p /home/steam/steamcmd" steam
    cd /home/steam/steamcmd

    printf "%s" "  Adding cron job..."
    ( sudo crontab -l 2>/dev/null | grep -Fv ezsteamcmd_cron.sh; printf -- "*/5 * * * * /usr/etc/ezsteamcmd/ezsteamcmd_cron.sh\n" ) | sudo crontab
    status

    printf "%s" "  Checking ia32-libs..."
    sudo apt-get -y install ia32-libs 1>/dev/null 2>/dev/null
    status InstallAlt32Libs

    printf "%s" "  Downloading steamcmd_linux.tar.gz..."
    sudo wget -cq http://media.steampowered.com/installer/steamcmd_linux.tar.gz
    status

    printf "%s" "  Deflating..."
    sudo su -c "tar -xvzf /home/steam/steamcmd/steamcmd_linux.tar.gz 1>/dev/null" steam
    status

    Update

    printf "%s" "  Installing 32-bit libraries..."
    sudo mkdir -p /home/steam/.steam/sdk32
    sudo cp -f /home/steam/steamcmd/linux32/* /home/steam/.steam/sdk32/
    status

    sudo rm -f /home/steam/steamcmd/steamcmd_linux.tar.gz
  else
    InstallDS $2
  fi

}

Update(){
    Title "Checking for updates"
    local APPID="`GetServerAppID`"
    local APPNAME="`GetServerName`"

    printf "%s" "  Checking file limit..."
    sudo su -c "ulimit -n 2048" steam
    status

    printf "%s" "  Checking for updates for Steam..."
    sudo su -c "bash /home/steam/steamcmd/steamcmd.sh +login anonymous +quit 1>/dev/null" steam
    status

    if [[ "$APPID" != "" && "$APPID" -lt "99999" ]]; then
      printf "%s" "  Checking for updates for $APPNAME..."
      sudo su -c "bash /home/steam/steamcmd/steamcmd.sh +login anonymous +app_update $APPID validate +quit 1>/dev/null" steam
      status
    fi

    printf "%s" "  Updating 32-bit libraries..."
    sudo mkdir -p /home/steam/.steam/sdk32
    sudo cp -f /home/steam/steamcmd/linux32/* /home/steam/.steam/sdk32/
    status

}

SambaOn(){

  if [ ! -f /usr/sbin/smbd ]; then
    Title "Start Samba"

    printf "%s" "  Installing Samba..."
    sudo apt-get update 1>/dev/null 2>/dev/null
    sudo apt-get -y install samba 1>/dev/null 2>/dev/null
    status

    sudo stop smbd 1>/dev/null 2>/dev/null
    sudo stop nmbd 1>/dev/null 2>/dev/null
    sudo killall smbd 1>/dev/null 2>/dev/null
    sudo killall nmbd 1>/dev/null 2>/dev/null

    printf "Enter the SMB user name: "; read SambaUserName
    sudo smbpasswd -a $SambaUserName
    sudo smbpasswd -e $SambaUserName
    printf "Enter the SMB share name: "; read SambaName
    printf "Enter the SMB share workgroup: "; read Workgroup
    sudo su -c "echo \"[global]
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
\" >/etc/samba/smb.conf" root

    separator;printf "\n"
  fi
  
  if top -bn 1 | grep "smbd" >/dev/null; then
    redtext "  Samba is already running"
  else
    printf "%s" "  Starting Samba..."
    sudo start smbd 1>/dev/null 2>/dev/null
    sudo start nmbd 1>/dev/null 2>/dev/null
    status
  fi

}

SambaOff(){
  Title "Stop Samba"
  
  printf "%s" "  Stopping Samba..."
  sudo stop smbd 1>/dev/null 2>/dev/null
  sudo stop nmbd 1>/dev/null 2>/dev/null
  status
  
}


AutoStartOn(){
    Title "Autostart On"

    printf "%s" "  Adding ezsteamcmd_autostart cron job..."
    ( sudo crontab -l 2>/dev/null | grep -Fv ezsteamcmd_autostart.sh; printf -- "@reboot /usr/etc/ezsteamcmd/ezsteamcmd_autostart.sh\n" ) | sudo crontab
    status

}

AutoStartOff(){
    Title "Autostart Off"

    printf "%s" "  Removing ezsteamcmd_autostart cron job..."
    ( sudo crontab -l 2>/dev/null | grep -Fv ezsteamcmd_autostart.sh; printf -- "\n" ) | sudo crontab
    status

}


Usage(){
  Title "EZSteamCMD"
  
  longline "    `bold ex: \'ezsteamcmd install 4020\' or \'ezsteamcmd autostart on\'`\n\n  `bold install`: Installs a Steam dedicated server.  Specify the server by steam_appid.  Also, \'ezsteamcmd install minecraft\' installs a minecraft server.\n  `bold update`: Updates steamcmd and any installed dedicated server.\n  `bold remove`: Removes the installed dedicated server.\n  `bold start`: Starts the installed dedicated server.\n  `bold stop`: Stops the installed dedicated server.\n  `bold \"restart\"`: Restarts a specified server.  This may be a soft-restart.\n  `bold \"samba [on|off]\"`: Starts or stops the Samba Steam share.  \n  `bold \"autostart [on|off]\"`: Enables or disables autostart of the specified server on startup."

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
