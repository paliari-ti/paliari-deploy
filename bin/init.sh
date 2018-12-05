#!/usr/bin/env bash

set -e
RUN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"
source ${RUN_DIR}/lib/colors.sh
source ${RUN_DIR}/lib/yaml.sh

DIR=$1
FILE_STAGE=".deploy/stage-$2.yml"

echo
echo_blue 'SETUP DEPLOY REMOTE---------------------------'
echo

# Validate APP path exists
if [[ ! -d "$DIR" ]]; then
    echo_red "APP path is required!"
    exit 1
fi
cd $DIR
if [[ -f ${FILE_STAGE} ]]; then
  echo_yellow "Setup stage $FILE_STAGE"
  create_variables ${FILE_STAGE}
  cmd="mkdir -p $deploy_remote_path && cd $deploy_remote_path"
  cmd="$cmd && mkdir -p releases && mkdir -p shared && mkdir -p current"
  if [[ ${deploy_publish_git_url} ]]; then
    cmd="$cmd && rm -rf repo && git clone --depth 1 $deploy_publish_git_url repo"
  else
    cmd="$cmd && mkdir -p repo/.deploy"
  fi
  echo_yellow "Exec remote: $cmd"
  ssh -t ${deploy_remote_user}@${deploy_remote_host} "$cmd"
  echo_green "Success full setup remote"
else
  echo_red "Config file not found in the '$DIR/.deploy/'"
  exit 1
fi

echo
echo_blue 'FINISHED SETUP DEPLOY REMOTE-----------------'
echo
