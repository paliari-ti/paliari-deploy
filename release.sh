#!/usr/bin/env sh

set -e

DIR=$1
version=${2:-$(date +%s)}

echo
echo '---------------------------'
echo 'START SERVER RELEASE'
echo

if [[ ! -d "$DIR" ]]; then
    echo "Path is required!"
    echo
    exit
fi
cd $DIR
if [[ ! -d "repo" ]]; then
  echo "Repo not found in '$DIR'"
  exit
fi
if [[ -f "repo/.deploy-hooks-repo" ]]; then
  while read -r call; do
    echo "exec: [$call] in repo"
    cd repo/
    $call
  done < "repo/.deploy-hooks-repo"
fi
echo
cd $DIR

mkdir -p releases/$version
echo "Repo copy to releases/$version"
cp -a repo/* releases/$version/
if [[ -d "shared" ]]; then
  for f in $DIR/shared/* $DIR/shared/.env; do
    ln -sf $f $DIR/releases/$version/
  done
  echo "Created shared links in releases/$version/"
fi

if [[ -f "repo/.deploy-hooks-releases" ]]; then
  while read -r call; do
    echo "exec: [$call] in releases/$version"
    cd releases/$version/
    $call
  done < "repo/.deploy-hooks-releases"
fi
echo
cd $DIR

echo "Replece current to releases/$version/"
cp -a $DIR/releases/$version $DIR/current_tmp
mv current current_old
mv current_tmp current
rm -rf current_old

echo
echo 'FINISHED SERVER RELEASE'
echo '------------------------------'
echo
