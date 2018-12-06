#!/usr/bin/env bash

set -e

RUN_DIR="$( cd "$(dirname $0)/../" && pwd )"
source ${RUN_DIR}/lib/colors.sh
source ${RUN_DIR}/lib/yaml.sh

FILE_STAGE=".deploy/stage-$1.yml"
if [[ ! -f ${FILE_STAGE} ]]; then
  echo_red "Config file '$FILE_STAGE' not found!"
  exit 1
fi

create_variables ${FILE_STAGE}

remote="${deploy_remote_user}@${deploy_remote_host}"
remote_path=${deploy_remote_path}

ssh -t ${remote} "cd $remote_path/ && paliari-deploy releases-list"
