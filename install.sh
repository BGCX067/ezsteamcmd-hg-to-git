#!/bin/sh
echo "  ezsteamcmd - Install"
echo "========================================================="
echo "  This script will install ezsteamcmd to /usr/bin."
echo "  Afterwards it can be called with the command ezsteamcmd"
echo ""
printf "%s" "    Proceed?  y/n: "; read LINE
if [ "$LINE" = "y" ]; then
  mkdir -p /usr/etc
  mkdir -p /usr/bin
  sudo cp -f ./ezsteamcmd.sh /usr/bin/ezsteamcmd
  sudo cp -r ./ezsteamcmd /usr/etc/
  sudo chmod +x /usr/bin/ezsteamcmd
fi
echo ""
echo "  ezsteamcmd requires sudo permission.  This script can"
echo "  add ezsteamcmd to your sudoers file so a password is"
echo "  not required each time."
echo ""
printf "%s" "  Add ezsteamcmd to the sudoers file? y/n: "; read LINE
if [ "$LINE" = "y" ]; then
  sudo echo "#!/bin/bash
  echo \"\`sudo cat /etc/sudoers | grep -Fv ezsteamcmd; echo '%sudo ALL=NOPASSWD: /usr/bin/ezsteamcmd'\`\" >/etc/sudoers" >/tmp/ezsteamcmd.sudoersmod
  sudo chmod a+rx /tmp/ezsteamcmd.sudoersmod
  sudo /tmp/ezsteamcmd.sudoersmod
  sudo rm -rf /tmp/ezsteamcmd.sudoersmod
fi
echo ""
echo "  ezsteamcmd - Install complete"
echo "  Run uninstall.sh to uninstall ezsteamcmd"
echo ""
exit 0
