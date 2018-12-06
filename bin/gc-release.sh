#!/usr/bin/env bash

set -e

RUN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"
source ${RUN_DIR}/lib/colors.sh

DIR=$(pwd)
MAX=${1:-10}

echo
echo_yellow "Garbage Collection in releases"

# Check releases path exists in the APP
if [[ ! -d "releases" ]]; then
    echo_red "Releases path not found in '$DIR'"
    exit 1
fi

echo
# Loop in the releases order by time
count=0
for f in $(ls -t releases/)
do
  if [[ ${count} -gt ${MAX} ]]; then
    echo "DELETED $f"
    rm -rf "releases/$f"
  fi
  count=$((count+1))
done
echo
echo_green "Finished Garbage Collection"
echo
