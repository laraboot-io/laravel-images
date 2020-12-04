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

~/.config/composer/vendor/bin/laravel $@
