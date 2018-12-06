#!/usr/bin/env bash

set -e

echo
rm -f /usr/local/bin/paliari-deploy
bash -c "$(curl -fsSL https://raw.githubusercontent.com/paliari-ti/paliari-deploy/master/deploy.sh)" > /usr/local/bin/paliari-deploy
chmod +x /usr/local/bin/paliari-deploy

echo "See docs in the project:"
echo "https://github.com/paliari-ti/paliari-deploy"
echo
echo "Paliari deploy successfully installed"
echo
