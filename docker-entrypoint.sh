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

composer_cmd() {
  echo "🧙 Running composer command : $*"
  composer "$@"
}

require_dev(){
  # Used to build several pieces of the foundation project
  composer_cmd require --dev laravel-shift/blueprint
  # Used to replace configuration values via CLI
  composer_cmd require --dev oscarnevarezleal/laravel-sed:dev-dev
  # Used to tests the generated code
  composer_cmd require --dev jasonmccreary/laravel-test-assertions
  # Used to include cloud-ready capabilities in the generated project
  composer_cmd require bref/laravel-bridge
}

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
  require_dev
  composer require laravel/breeze --dev
  php artisan breeze:install
  npm install && npm run dev

  zip -qr breeze.zip . &&
    mv breeze.zip /usr/app/dist
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
    require_dev &&
    zip -qr default.zip . &&
    mv default.zip /usr/app/dist
}

#~/.config/composer/vendor/bin/laravel $@

mkdir -p /usr/app/dist
create_default_setup
create_breeze_setup

#aws s3 cp /usr/app/default.zip s3://snapshots.laraboot.io/laravel-images/default.zip
#aws s3 cp /usr/app/breeze.zip s3://snapshots.laraboot.io/laravel-images/breeze.zip
