#!/bin/bash

echo "BEGIN: server.sh (apache)"

if [[ ! ${COMPOSE_PROFILES} =~ "apache" ]]; then
  echo "server.sh: No Apache environment"
  exit 0
fi

if test ! -f .build/public/.htaccess; then
  cp -v .devcontainer/docker/apache/.htaccess .build/public
fi

sudo find .build/public -name .htaccess -exec chmod -c 0660 {} \;
sudo find var -name .htaccess -exec chmod -c 0660 {} \;
sudo find .build/public -name index.html -exec chmod -c 0660 {} \;

sudo apachectl -k restart
echo "Devcontainer: Apache server started"

echo "END: server.sh (apache)"
exit 0
