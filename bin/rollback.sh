#!/usr/bin/env bash

set -e

RUN_DIR="$( cd "$(dirname $0)/../" && pwd )"
source "$RUN_DIR/lib/colors.sh"

FILE_STAGE=".deploy/stage-$1.yml"
version=$2

echo_green "Start Rollback --------------------------------"

if [[ ! -f ${FILE_STAGE} ]]; then
  echo_red "Config file '$FILE_STAGE' not found!"
  exit 1
fi
# Validate Release path exists in the APP
if [[ ! "$version" || ! -d "releases/$version" ]]; then
  echo "Release version '$version' not found in '$DIR'"
  exit 1
fi

create_variables ${FILE_STAGE}

remote="${deploy_remote_user}@${deploy_remote_host}"
remote_path=${deploy_remote_path}

ssh -t ${remote} "cd $remote_path/ && paliari-deploy set-current-release $version"

echo
echo_green "Rollback Finished -----------------------------"
echo
