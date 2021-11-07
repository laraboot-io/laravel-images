#!/usr/bin/env bash

#          __                     __                __
#         / /   ____ __________ _/ /_  ____  ____  / /_
#        / /   / __ `/ ___/ __ `/ __ \/ __ \/ __ \/ __/
#       / /___/ /_/ / /  / /_/ / /_/ / /_/ / /_/ / /_
#      /_________,_/_/   \__,_/_.___/\____/\____/\__/
#

cd /usr/app

echo "🧙 inertia was selected. Creating an empty laravel application first."

if [ ! -d "/usr/app/mount/laravel-app" ]; then
  laravel new inertia
else
  mkdir -p inertia && cp -r /usr/app/mount/laravel-app/* inertia
fi
# shellcheck disable=SC2164
cd inertia

/usr/app/scripts/require.sh && composer require inertiajs/inertia-laravel &&
composer_cmd dump-autoload -o --apcu &&
npm install

zip -qr inertia.zip . &&
  mv inertia.zip /usr/app/dist
