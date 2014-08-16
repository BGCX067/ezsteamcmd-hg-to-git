#!/bin/sh
sudo cp -f ./ezsteamcmd.sh /usr/bin/ezsteamcmd
sudo cp -r ./ezsteamcmd /usr/etc/
sudo chmod +x /usr/bin/ezsteamcmd
ezsteamcmd $@
