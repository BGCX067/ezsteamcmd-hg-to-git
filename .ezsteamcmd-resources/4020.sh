#!/bin/sh
. ./.ezsteamds-resources/jlib.sh

APPID="`basename $0 | cut -d "." -f1`"
printf "\n\n"; bold "  Using generic installer for AppID $APPID"; separator; printf "\n"
sh ./installerfiles/genericinstall.sh $APPID
