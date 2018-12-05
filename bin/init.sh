#!/usr/bin/env sh

set -e
RUN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"
source ${RUN_DIR}/lib/colors.sh
source ${RUN_DIR}/lib/yaml.sh

DIR=$1
version=${2:-$(date +%s)}

echo
echo_blue 'DEPLOY SETUP IN THE SERVER-----------------------'
echo

# Validate APP path exists
if [[ ! -d "$DIR" ]]; then
    echo_red "APP path is required!"
    exit 1
fi
cd $DIR
if [[ ! -f "$DIR/.deploy/stage.*.yml" ]]; then
  echo_red "Config file not found in the '$DIR/.deploy/'"
  exit 1
fi

echo
echo_green 'DEPLOYED SETUP IN THE SERVER-----------------------'
echo
