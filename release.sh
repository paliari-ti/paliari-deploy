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
mkdir -p releases/$version
echo "Repo copy to releases/$version"
cp -a repo/* releases/$version/
if [[ -d "shared" ]]; then
  for f in $DIR/shared/* $DIR/shared/.env; do
    ln -sf $f $DIR/releases/$version/
  done
  echo "Created shared links in releases/$version/"
fi
if [[ -d "hooks" ]]; then
  echo exec hooks
  for f in hooks/* ; do
      echo "call: $f"
      call=$(cat $f)
      cd releases/$version/
      $call
  done
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
