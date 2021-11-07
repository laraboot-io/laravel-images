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

# Used to build several pieces of the foundation project
composer_cmd require --dev laravel-shift/blueprint
# Used to replace configuration values via CLI
composer_cmd require --dev oscarnevarezleal/laravel-sed:dev-dev
# Used to tests the generated code
composer_cmd require --dev jasonmccreary/laravel-test-assertions
# Used to include cloud-ready capabilities in the generated project
composer_cmd require bref/laravel-bridge
