#!/usr/bin/env bash

set -e

cd ~/
rm -rf paliari-deploy
git clone --depth 1 https://github.com/paliari-ti/paliari-deploy.git
cd paliari-deploy/
rm -f /usr/local/bin/paliari-deploy
ln -s ~/paliari-deploy/deploy.sh /usr/local/bin/paliari-deploy
echo
echo "Success"
echo
