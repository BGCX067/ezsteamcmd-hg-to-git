#!/bin/sh
. ./.ezsteamds-resources/jlib.sh


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

su -c "bash /home/steam/steamcmd/steamcmd.sh +login $USERNAMEPASSWORD +app_update $APPID validate +quit" steam