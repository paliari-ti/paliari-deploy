#!/usr/bin/env bash

set -e

RUN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"
source ${RUN_DIR}/lib/yaml.sh
source ${RUN_DIR}/lib/colors.sh

DIR=$(pwd)
APP_STAGE=$1
FILE_STAGE=".deploy/stage-$1.yml"

echo
echo_blue "PUBLISH '$APP_STAGE' ---------------------------"
echo

if [[ ! -f ${FILE_STAGE} ]]; then
  echo_red "Config file not found in the '$DIR/.deploy/'"
  exit 1
fi

paliari-deploy self-update

create_variables ${FILE_STAGE}

remote="${deploy_remote_user}@${deploy_remote_host}"
remote_path=${deploy_remote_path}
if [[ ${deploy_publish_git_url} ]]; then
  branch=${deploy_publish_git_branch:-master}
  cmd="cd $remote_path/repo && git fetch --depth 1 origin master && git reset --hard origin/$branch"
  echo $cmd
  ssh -t ${remote} "$cmd"
elif [[ ${deploy_publish_scp_path} ]]; then
  ssh -t ${remote} "cd $remote_path/repo && rm -rf ${deploy_publish_scp_path}"
  scp ${FILE_STAGE} ${remote}:${remote_path}/repo/${FILE_STAGE}
  scp ${DIR}/.deploy/hooks.yml ${remote}:${remote_path}/repo/.deploy/hooks.yml
  scp -r ${deploy_publish_scp_path} ${remote}:${remote_path}/repo/
elif [[ ${deploy_publish_script} ]]; then
  ${deploy_publish_script}
fi

ssh -t ${remote} "cd $remote_path/ && paliari-deploy self-update && paliari-deploy release"

echo
echo_green "PUBLISHED '$APP_STAGE' -------------------------"
echo
