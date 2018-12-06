#!/usr/bin/env bash

set -e

RUN_DIR="$( cd "$(dirname $0)/../" && pwd )"
source "$RUN_DIR/lib/colors.sh"

cd "$RUN_DIR"

git fetch --quiet --depth 1 origin master

if [ $(git rev-list HEAD...origin/master --count) -gt 0 ] ; then
  echo_red "\"paliari-deploy\" outdated."
  echo_blue "Updating \"paliari-deploy\"..."
  git reset --quiet --hard origin/master
  echo_green "\"paliari-deploy\" updated."
  echo
fi
echo
