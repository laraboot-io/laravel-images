#!/usr/bin/env bash
set -eu
set -o pipefail

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOTDIR="$(cd "${PROGDIR}/.." && pwd)"

# shellcheck source=SCRIPTDIR/.util/tools.sh
source "${PROGDIR}/.util/tools.sh"

# shellcheck source=SCRIPTDIR/.util/print.sh
source "${PROGDIR}/.util/print.sh"

# shellcheck source=SCRIPTDIR/.util/git.sh
source "${PROGDIR}/.util/git.sh"

function main() {
  local withBreeze withJetstream buildpackFile

  withBreeze=0
  withJetstream=0
  buildpackFile=""

  while [[ "${#}" != 0 ]]; do
    case "${1}" in
    --use-token | -t)
      shift 1
      token::fetch
      ;;

    --with-breeze | -wb)
      shift 1
        withBreeze=1
        # laraboot task add @core/laravel-starterkit-buildpack --format=file -vvv
      ;;

    --with-jetstream | -wj)
      shift 1
        withJetstream=1
        # laraboot task add @core/laravel-starterkit-buildpack --format=file -vvv
      ;;

    --help | -h)
      shift 1
      usage
      exit 0
      ;;

    "")
      # skip if the argument is empty
      shift 1
      ;;

    *)
      util::print::error "unknown argument \"${1}\""
      ;;
    esac
  done

#  laraboot::install

  tmpdir=$(mktemp -d)

  laraboot::setup-starterkit $withBreeze $withJetstream $tmpdir
  laraboot::build
  # in the form of `from directory` `into directory`
  laraboot::merge $tmpdir $LARAVEL_DIR_APP

}

function usage() {
  cat <<-USAGE
features.sh [OPTIONS]

OPTIONS
  --help       -h  prints the command usage
  --with-breeze -wb Breeze support
  --with-jetstream -wj Jetstream support
  --use-token  -t  use GIT_TOKEN from lastpass
USAGE
}

function laraboot::setup-starterkit() {
  local withBreeze withJetstream buildpackFile cwd
  withBreeze=$1
  withJetstream=$2
  cwd=$3

  if [[ "$withBreeze" -eq "1" && "$withJetstream" -eq "1" ]]; then
    util::print::title "Setup with breeze & jetstream 🧙"
    buildpackFile="${ROOTDIR}/config/buildpack-full-starterkit.yml"
  else
    if [[ "$withBreeze" -eq "1" ]]; then
        util::print::title "Setup with breeze only 🧙"
        buildpackFile="${ROOTDIR}/config/buildpack-breeze-only.yml"
      else
        util::print::title "Setup with breeze only 🧙"
        buildpackFile="${ROOTDIR}/config/buildpack-jetstream-only.yml"
      fi
  fi

  cd $cwd
  laraboot new app --skip-laravel-installer
  cd app
  laraboot task add @core/laravel-starterkit-buildpack --format=file
  cp $buildpackFile buildpack.yml
}

function laraboot::install() {
  npm i -g @laraboot-io/cli
}

function laraboot::build(){
  laraboot build -vvv
}

function laraboot::merge(){
  source=$1
  dest=$2
  echo " $source -> $dest"
}

main "${@:-}"