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
  echo "Breeze was selected. Creating an empty laravel application first."

  if [ ! -d "/usr/app/mount/laravel-app" ]; then
    laravel new breeze
  else
    mkdir -p app && cp -r /usr/app/mount/laravel-app/* app
  fi
  cd app || error_exit 'Error creating an empty laravel application' 255
  composer require laravel/breeze --dev
  php artisan breeze:install
  cd ..
}

create_default_setup() {
  echo "Default was selected. Creating an empty laravel application first."
  if [ ! -d "/usr/app/mount/laravel-app" ]; then
    laravel new default
  else
    mkdir -p app && cp -r /usr/app/mount/laravel-app/* app
  fi
  cd app || error_exit 'Error creating an empty laravel application' 255
  cd ..
}

#~/.config/composer/vendor/bin/laravel $@

$@
