#!/bin/sh

printf "%s" "  Remove Steam and steamcmd as well? y/n: "
read LINE
if [ $LINE = "y" ]; then ezsteamcmd remove; fi
printf "\n%s" "  Uninstalling ezsteamcmd..."
sudo rm -f /usr/bin/ezsteamcmd
printf "%s" "."
sudo rm -rf /usr/etc/ezsteamcmd/
printf "%s" "."
printf "%s\n\n" "  Done."
