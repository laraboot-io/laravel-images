#!/usr/bin/env bash

#          __                     __                __
#         / /   ____ __________ _/ /_  ____  ____  / /_
#        / /   / __ `/ ___/ __ `/ __ \/ __ \/ __ \/ __/
#       / /___/ /_/ / /  / /_/ / /_/ / /_/ / /_/ / /_
#      /_________,_/_/   \__,_/_.___/\____/\____/\__/
#
composer_cmd() {
  echo "🧙 Running composer command : $*"
  composer "$@"
}

cd /usr/app


echo "🧙 Default was selected. Creating an empty laravel application first."

mkdir -p default && cp -r /usr/app/mount/laravel-app/* default

# shellcheck disable=SC2164
cd default &&
  /usr/app/scripts/require.sh &&
  composer_cmd update &&
  composer_cmd dump-autoload -o --apcu &&
  zip -qr default.zip . &&
  mv default.zip /usr/app/dist

ls /usr/app/dist
