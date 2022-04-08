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
      ;;

    --with-jetstream | -wj)
      shift 1
        withJetstream=1
      ;;

    --simple)
      shift 1
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

  laraboot::install

  ftdir=$(mktemp -d)

  laraboot::setup-starterkit $withBreeze $withJetstream $ftdir
  # in the form of `from directory` `into directory`

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
  appName="app"

  if [[ "$withBreeze" -eq "1" && "$withJetstream" -eq "1" ]]; then
    util::print::title "Setup with breeze & jetstream 🧙"
    buildpackFile="${ROOTDIR}/config/buildpack-full-starterkit.yml"
    appName="full"
  else
    if [[ "$withBreeze" -eq "1" ]]; then
        util::print::title "Setup with breeze only 🧙"
        buildpackFile="${ROOTDIR}/config/buildpack-breeze-only.yml"
        appName="breeze"
      else
        util::print::title "Setup with jetstream only 🧙"
        buildpackFile="${ROOTDIR}/config/buildpack-jetstream-only.yml"
        appName="jetstream"
      fi
  fi

  cd $cwd
  laraboot new $appName --php-version=8.0.*
  cd $appName
  laraboot task add @core/laravel-starterkit-buildpack --format=file
  laraboot task add nodejs --imageUri=gcr.io/paketo-buildpacks/nodejs --format=external --prepend -vvv
  cat $buildpackFile >> buildpack.yml
  laraboot build -vvv
  docker images $appName

  ls -ltah
  layer=$(mktemp -d)
  sid=$(docker run -d $appName --entrypoint willfail)
  docker cp $sid:/workspace $layer
  # not interested in the vendor folder
  rm -rf $layer/workspace/vendor
  laraboot::merge $layer/workspace $LARAVEL_DIR_APP
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
  echo "merge $source -> $dest"
  ls $source
  ls $dest
  rsync -a $source/ $dest
}

main "${@:-}"