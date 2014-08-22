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
    if [ $@ ]; then
      $@
    else
      echo "\033[${scol}G\033[1;31mError\033[0;39m"
    fi
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

Title(){
  echo "\n\033[7m     $@     \033[0m"
  separator "="
}  

longline() {
	cols=$(get_cols); [ "$cols" ] || cols=80
	echo "$@" | fold -sw$cols
}

GetServerAppID(){
  echo "`cat /home/steam/.ezsteamcmdappid 2>/dev/null`"
}

GetServerName(){
  echo "`find /home/steam/Steam/steamapps/common/ -maxdepth 1 -type d 2>/dev/null | tail -1 | rev | cut -d "/" -f1 | rev`"
}
