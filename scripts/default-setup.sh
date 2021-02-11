#!/usr/bin/env bash

#          __                     __                __
#         / /   ____ __________ _/ /_  ____  ____  / /_
#        / /   / __ `/ ___/ __ `/ __ \/ __ \/ __ \/ __/
#       / /___/ /_/ / /  / /_/ / /_/ / /_/ / /_/ / /_
#      /_________,_/_/   \__,_/_.___/\____/\____/\__/
#

cd /usr/app

echo "🧙 Default was selected. Creating an empty laravel application first."

if [ ! -d "/usr/app/mount/laravel-app" ]; then
  laravel new default
else
  mkdir -p default && cp -r /usr/app/mount/laravel-app/* default
fi

# shellcheck disable=SC2164
cd default
/usr/app/scripts/require.sh

zip -qr default.zip . &&
  mv default.zip /usr/app/dist
