#!/usr/bin/env sh
set -e

BASH_SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $BASH_SRC_DIR/lib/yaml.sh

action=$1

echo $action

create_variables config.default.yml

for i in ${!hooks_release_before[*]}; do
  echo "a: $i: ${hooks_release_before[$i]}"
done
