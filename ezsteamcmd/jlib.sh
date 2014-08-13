#!/bin/sh

get_cols() {
	stty size 2>/dev/null | cut -d " " -f 2
}

status() {
  local check=$?
  local cols=$(get_cols)
  [ "$cols" ] || cols=80
  local scol=$(($cols - 7))
  if [ $check = 0 ]; then
    echo "\033[${scol}G\033[1;32mOK\033[0;39m"
  else
    echo "\033[${scol}G\033[1;31mError\033[0;39m"
  fi    
}

separator() {
  if [ $1 ]; then local sepchar="$1"; else local sepchar="_"; fi
  local cols=$(get_cols)
  [ "$cols" ] || cols=80
  for x in $(seq 1 $cols); do
    echo -n "$sepchar"
  done && echo ""
}

bold(){
  echo "\033[1m$@\033[0m"
}

redtext(){
  echo "\033[31m$@\033[0m"
}

invtext(){
  echo "\033[7m$@\033[0m"
}  

longline() {
	cols=$(get_cols); [ "$cols" ] || cols=80
	echo "$@" | fold -sw$cols
}

GetServerAppID(){
  return "`cat /home/steam/Steam/ezsteamappid`"
}


GetServerName(){
  return "`find /home/steam/Steam/steamapps/common/ -maxdepth 1 -type d | tail -1`"
}

GetServerPID(){
  return "`cat /home/steam/Steam/*.pid`"
}
