#!/usr/bin/env sh

set -e

DIR=$1
MAX=${2:-10}

echo
echo "Garbage Collection in releases"

# Check APP path exists
if [[ ! "$DIR" || ! -d "$DIR" ]]; then
    echo "Path is required!"
    exit 1
fi
cd $DIR

# Check releases path exists in the APP
if [[ ! -d "releases" ]]; then
    echo "Releases path not found in '$DIR'"
    exit 1
fi
echo
count=0
# Loop in the releases order by time
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
echo
