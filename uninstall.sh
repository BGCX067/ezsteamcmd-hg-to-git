#!/bin/sh
echo "  Remove Steam (including all installed Steam software)"
printf "%s" "  and steamcmd as well? y/n: "
read LINE
if [ $LINE = "y" ]; then ezsteamcmd remove; fi
printf "\n%s" "  Uninstalling ezsteamcmd..."
sudo rm -f /usr/bin/ezsteamcmd
printf "%s" "."
sudo rm -rf /usr/etc/ezsteamcmd/
printf "%s" "."
echo "#!/bin/bash
echo \"\`sudo cat /etc/sudoers | grep -Fv ezsteamcmd\`\" >/etc/sudoers
" >/tmp/ezsteamcmd.sudoersmod
printf "%s" "."
sudo chmod a+rx /tmp/ezsteamcmd.sudoersmod
printf "%s" "."
sudo /tmp/ezsteamcmd.sudoersmod
printf "%s\n\n" "  Done."
exit 0
