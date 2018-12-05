#!/usr/bin/env sh
set -e

RUN_DIR="$(dirname "$(realpath "$0")")"

source ${RUN_DIR}/lib/colors.sh

action=$1

if [[ '--help' == "$action" || '-h' == "$action" ]]; then
	cat "$RUN_DIR/help.txt"
	echo
	exit
fi

set -- "${@:2:$#}"
if [ -f "$RUN_DIR/bin/$action.sh" ]; then
  ${RUN_DIR}/bin/$action.sh $@
else
  echo_red "COMMAND \"$action\" not found!"
	echo
	cat "$RUN_DIR/help.txt"
	echo
fi
