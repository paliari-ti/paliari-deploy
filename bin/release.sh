#!/usr/bin/env sh

set -e

BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DIR=$1
version=${2:-$(date +%s)}

echo
echo '---------------------------'
echo 'START SERVER RELEASE'
echo

# Validate APP path exists
if [[ ! -d "$DIR" ]]; then
    echo "Path is required!"
    echo
    exit 1
fi
cd $DIR
# Validate repo path exists in the APP
if [[ ! -d "repo" ]]; then
  echo "Repo not found in '$DIR'"
  exit 1
fi

# Exec hook in the repo
if [[ -f "repo/.deploy/hooks-repo" ]]; then
  while read -r call; do
    echo "exec: [$call] in repo"
    cd repo/
    $call
  done < "repo/.deploy/hooks-repo"
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
  echo "Created shared links in releases/$version/"
fi

# Exec hooks in the release
if [[ -f "repo/.deploy/hooks-releases" ]]; then
  while read -r call; do
    echo "exec: [$call] in releases/$version"
    cd releases/$version/
    $call
  done < "repo/.deploy/hooks-releases"
fi
echo
cd $DIR

# Link current in the release version
$BIN_DIR/set-current-release.sh $DIR $version

echo
echo 'FINISHED SERVER RELEASE'
echo '------------------------------'
echo
