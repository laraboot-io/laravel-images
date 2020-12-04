#!/usr/bin/env bash

#          __                     __                __
#         / /   ____ __________ _/ /_  ____  ____  / /_
#        / /   / __ `/ ___/ __ `/ __ \/ __ \/ __ \/ __/
#       / /___/ /_/ / /  / /_/ / /_/ / /_/ / /_/ / /_
#      /_________,_/_/   \__,_/_.___/\____/\____/\__/
#

whoami
id -u
id -g
php -v
php -m
node -v
composer --version
laravel --version

create_breeze_setup() {
  cd /usr/app
  echo "Breeze was selected. Creating an empty laravel application first."

  if [ ! -d "/usr/app/mount/laravel-app" ]; then
    laravel new breeze
  else
    mkdir -p breeze && cp -r /usr/app/mount/laravel-app/* breeze
  fi
  # shellcheck disable=SC2164
  cd breeze
  composer require laravel/breeze --dev
  php artisan breeze:install
  zip breeze.zip . &&
    mv breeze.zip /usr/app
}

create_default_setup() {
  cd /usr/app
  echo "Default was selected. Creating an empty laravel application first."
  if [ ! -d "/usr/app/mount/laravel-app" ]; then
    laravel new default
  else
    mkdir -p default && cp -r /usr/app/mount/laravel-app/* default
  fi
  cd default &&
    zip default.zip . &&
    mv default.zip /usr/app
}

#~/.config/composer/vendor/bin/laravel $@

create_default_setup
create_breeze_setup
