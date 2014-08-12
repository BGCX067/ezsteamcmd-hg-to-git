#!/bin/sh
. ./.ezsteamds-resources/jlib.sh


#_______________________________________________________Miscellaneous

if [[ ! -f /home/steam/steamcmd/steamcmd.sh && ! -f /home/steam/Steam/config/config.vdf ]]; then
  printf "\n\n"; redtext "  Please run installsteamcmd.sh first!"; separator
  longline "If you already have, perhaps it did not install correctly.  Ensure proper hardware requirements and check network connectivity."
  printf "\n\n"
fi

if [ ! $1 ]; then
  printf "\n\n"; redtext "  Please specify the AppID"; separator
  printf "\n%s\n" "  Example:  sh installds.sh 4020"
  printf "%s\n\n" "  AppID's are viewable at http://developer.valvesoftware.com/wiki/Steam_Application_IDs"
  exit 0
fi

if [ -f ./installerfiles/$1.sh ]; then
  sh ./installerfiles/$1.sh
else
  printf "\n\n"; redtext "  Installation script for AppID $1 not found"; separator
  longline "This means I have not written an application specific install script for this dedicated server.  I also have not yet written a generic installer script.  This is because I would like to write application specific scripts in most cases, but will do so on request.  To request support please navigate to https://code.google.com/p/steamcmd4slitaz/issues.  There you can check for the existance of your request, and make a subsequent request if needed.  You can also check for updates that might include the applications specific installer script you seek.  I will also accept requests via email at danielikard@gmail.com if necessary."
  printf "\n%s\n" "AppID's are viewable at https://developer.valvesoftware.com/wiki/Steam_Application_IDs"
  separator
  printf "\n\n"
  exit 0
fi

printf "\n%s\n" `separator`; bold "  installds.sh complete!"; printf "\n"
exit 0
