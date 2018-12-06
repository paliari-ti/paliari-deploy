#!/usr/bin/env bash

set -e

RUN_DIR="$( cd "$(dirname $0)/../" && pwd )"
source "$RUN_DIR/lib/colors.sh"

# Check releases path exists in the APP
if [[ ! -d "releases" ]]; then
    echo_red "Releases path not found in '$(pwd)'"
    exit 1
fi

ls -l releases/ | awk '{print $9, $6, $7, $8}'
echo
