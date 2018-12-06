#!/usr/bin/env bash

set -e

echo
rm -f /usr/local/bin/paliari-deploy
curl -fsSL https://raw.githubusercontent.com/paliari-ti/paliari-deploy/master/deploy.sh > /usr/local/bin/paliari-deploy
chmod +x /usr/local/bin/paliari-deploy

echo "See docs in the project:"
echo "https://github.com/paliari-ti/paliari-deploy"
echo
printf "\033[32mPaliari deploy successfully installed\033[0m\n"
echo
