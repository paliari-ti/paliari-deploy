#!/usr/bin/env bash

set -e

RUN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"
source ${RUN_DIR}/lib/yaml.sh
source ${RUN_DIR}/lib/colors.sh

DIR=$1
version=${2:-$(date +%s)}

echo
echo_blue 'START SERVER RELEASE-----------------------'
echo

# Validate APP path exists
if [[ ! -d "$DIR" ]]; then
    echo_red "APP path is required!"
    exit 1
fi
cd $DIR
# Validate repo path exists in the APP
if [[ ! -d "repo" ]]; then
  echo_red "Repo not found in '$DIR'"
  exit 1
fi

if [[ -f "$DIR/.deploy/hooks.yml" ]]; then
  create_variables $DIR/.deploy/hooks.yml
fi

# Exec hook in the repo
if [[ "${deploy_hooks_repo[*]}" ]]; then
  cd repo/
  for i in ${!deploy_hooks_repo[*]}; do
    call=${deploy_hooks_repo[$i]}
    echo_yellow "exec: [$call] in the repo"
    $call
  done
fi
echo
cd $DIR

# Create release version
mkdir -p releases/$version
echo "Repo copy to releases/$version"
cp -a repo/* releases/$version/
# Link shared in release
if [[ -d "shared" ]]; then
  for f in $DIR/shared/* $DIR/shared/.env; do
    ln -sf $f $DIR/releases/$version/
  done
  echo_green "Created shared links in releases/$version/"
fi
echo

# Exec hooks in the release
if [[ "${deploy_hooks_releases[*]}" ]]; then
  cd releases/$version/
  for i in ${!deploy_hooks_releases[*]}; do
    call=${deploy_hooks_releases[$i]}
    echo_yellow "exec: [$call] in the release"
    $call
  done
fi
echo
cd $DIR

# Link current in the release version
$RUN_DIR/bin/set-current-release.sh $DIR $version
$RUN_DIR/bin/gc-release.sh $DIR

echo
echo_blue 'FINISHED SERVER RELEASE--------------------'
echo
