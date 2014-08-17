#!/bin/sh
. /usr/etc/ezsteamcmd/jlib.sh

APPID="$1"

if [ $2 ]; then
  printf "\n"
  bold "  Please enter the password for steam user,"
  printf "%s" "    `bold $USERNAME:` "
  read PASSWORD
  USERNAMEPASSWORD="$USERNAME $PASSWORD"
else
  USERNAMEPASSWORD="anonymous"
fi

Title "Installing steam_appid $1"
bold "  Downloading.  Please wait, this may take a bit..."
sleep 5
sudo su -c "bash /home/steam/steamcmd/steamcmd.sh +login $USERNAMEPASSWORD +app_update $APPID validate +quit" steam

printf "%s" "  Finishing steam_appid..."
sudo su -c "echo \"$APPID\" >/home/steam/.ezsteamcmdappid" steam
status

