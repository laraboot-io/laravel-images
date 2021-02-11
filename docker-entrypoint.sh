#!/usr/bin/env bash

php -v
node -v
composer --version

# shellcheck disable=SC2068
laravel $@
exit 0
