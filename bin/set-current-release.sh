#!/usr/bin/env bash

set -e

RUN_DIR="$( cd "$(dirname $0)/../" && pwd )"
DIR=$(pwd)
version=$1

source "$RUN_DIR/lib/colors.sh"

echo "Replece releases/$version to current"

# Validate APP path exists
if [[ ! -d "$DIR/releases" ]]; then
    echo "Path releases not found!"
    echo
    exit 1
fi

# Validate Release path exists in the APP
if [[ ! "$version" || ! -d "releases/$version" ]]; then
  echo "Release version '$version' not found in '$DIR'"
  exit 1
fi

# Link current in the release version
cp -a ${DIR}/releases/${version} ${DIR}/current_tmp
mv current current_old
mv current_tmp current
rm -rf current_old

echo_green "Linked current to '$version'"
echo
