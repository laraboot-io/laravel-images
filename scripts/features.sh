#!/usr/bin/env bash
#set -eu
#set -o pipefail

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

  cd $cwd || exit
  laraboot new $appName --php-version=8.0.* -vvv
  cd $appName || exit
  
  if [[ "$withBreeze" -eq "1" && "$withJetstream" -eq "1" ]]; then
    util::print::title "Setup with breeze & jetstream 🧙"
    buildpackFile="${ROOTDIR}/config/buildpack-full-starterkit.yml"
    appName="full"
    laraboot task add nodejs --imageUri=gcr.io/paketo-buildpacks/nodejs --format=external --prepend -vvv
    laraboot task add @core/laravel-starterkit-buildpack --format=file
  else
    if [[ "$withBreeze" -eq "0" && "$withJetstream" -eq "0" ]]; then
      appName="simple"
      buildpackFile="${ROOTDIR}/config/buildpack-simple.yml"
    else
      laraboot task add nodejs --imageUri=gcr.io/paketo-buildpacks/nodejs --format=external --prepend -vvv
      laraboot task add @core/laravel-starterkit-buildpack --format=file
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
  fi
  
  cat $buildpackFile >> buildpack.yml
  touch project.toml
  # Append model buildpack configuration
cat << EOF >> project.toml
[[build.env]]
name = 'BP_ENABLE_GIT'
value = 'true'

[[build.env]]
name = 'BP_ENABLE_GIT_COMMIT'
value = 'true'

[[build.env]]
name = 'BP_LARAVEL_MODEL_CLEANUP'
value = 'true'

[[build.env]]
name = 'BP_LARAVEL_MODEL_PROVIDER'
value = 'blueprint'
EOF

  jq ".name = \"$appName\"" laraboot.json > .laraboot.json && mv .laraboot.json laraboot.json

  laraboot::build
  docker images $appName

  layer=$(mktemp -d)
  sid=$(docker run -d $appName --entrypoint willfail)
  docker cp $sid:/workspace $layer
  # not interested in the vendor folder
  rm -rf $layer/workspace/vendor
  laraboot::merge $layer/workspace $LARAVEL_DIR_APP
}

function laraboot::install() {
  if ! command -v laraboot &> /dev/null
  then
      echo "<laraboot> could not be found; installing"
      npm i -g @laraboot-io/cli@next
  fi
  echo "Using laraboot-io/cli@$(laraboot --version)" 
}

function laraboot::build(){
  builderName=$(mktemp XXXXX)
  util::print::title "Listing existing docker images"
  docker ps -a --format '{{.Image}} {{.Names}}'
  util::print::title "Removing any existing builders"
  # remove existing builder if any (before)
  [ "$(docker ps -a --format '{{.Image}} {{.Names}}' | grep $builderName)" ] && docker rm -f $(docker ps -aq --filter name=$builderName)
  util::print::title "Building"
  laraboot build --bn=$builderName -vvv --cc
  util::print::title "Build finished"
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