#!/usr/bin/env sh
set -e

DIR=$1
version=$2

echo "Replece releases/$version to current"

# Validate APP path exists
if [[ ! "$DIR" || ! -d "$DIR" ]]; then
    echo "Path is required!"
    echo
    exit 1
fi
cd $DIR

# Validate Release path exists in the APP
if [[ ! "$version" || ! -d "releases/$version" ]]; then
  echo "Release version '$version' not found in '$DIR'"
  exit 1
fi
# Link current in the release version
cp -a $DIR/releases/$version $DIR/current_tmp
mv current current_old
mv current_tmp current
rm -rf current_old
echo
