#!/bin/sh
sudo cp -f ./ezsteamcmd.sh /usr/bin/ezsteamcmd
chmod +x /usr/etc/ezsteamcmd
sudo cp -r ./ezsteamcmd /usr/etc/
ezsteamcmd $@
