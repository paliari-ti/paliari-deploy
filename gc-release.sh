#!/usr/bin/env sh

set -e

DIR=$1
MAX=${2:-10}

echo
echo "---------------------------"
echo "Garbage Collection in releases"
echo
if [[ ! -d "$DIR" ]]; then
    echo "Path is required!"
    echo
    exit
fi
cd $DIR
if [[ ! -d "releases" ]]; then
    echo "Releases path not found in '$DIR'"
    echo
    exit
fi
echo
count=0
for f in $(ls -t releases/)
do
  if [[ $count -gt $MAX ]]; then
    echo "DELETED $f"
    rm -rf releases/$f
  fi
  count=$((count+1))
done
echo
echo "Finished Garbage Collection"
echo "---------------------------"
echo
