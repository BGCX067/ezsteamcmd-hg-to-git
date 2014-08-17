#!/bin/sh

if [ -f /home/steam/Steam/restart.ezsteamcmd ]; then
  echo "  ezsteamcmd restart file found.  Restarting..."
  rm -f /home/steam/Steam/restart.ezsteamcmd
  ezsteamcmd restart
fi

if [ -f /home/steam/Steam/restart.ezsteamcmd.txt ]; then
  echo "  ezsteamcmd restart file found.  Restarting..."
  rm -f /home/steam/Steam/restart.ezsteamcmd.txt
  ezsteamcmd restart
fi
