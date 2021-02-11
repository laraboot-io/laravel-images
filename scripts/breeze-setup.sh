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

echo "🧙 Breeze was selected. Creating an empty laravel application first."

if [ ! -d "/usr/app/mount/laravel-app" ]; then
  laravel new breeze
else
  mkdir -p breeze && cp -r /usr/app/mount/laravel-app/* breeze
fi

# shellcheck disable=SC2164
cd breeze
/usr/app/scripts/require.sh &&
composer_cmd update &&
composer require laravel/breeze --dev &&
php artisan breeze:install &&
npm install && npm run dev

zip -qr breeze.zip . &&
  mv breeze.zip /usr/app/dist
