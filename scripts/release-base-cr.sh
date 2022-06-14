#!/usr/bin/env bash

set -eu
set -o pipefail

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=PROGDIR/.util/print.sh
source "${PROGDIR}/.util/print.sh"

function main() {
  
  local dir

  dir=$(pwd)

  while [[ "${#}" != 0 ]]; do
    case "${1}" in
    --help | -h)
      shift 1
      usage
      exit 0
      ;;

    --directory | -d)
        dir="$2"
        shift # past argument
        shift # past value
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

  cmd::build $dir
}

function usage() {
  cat <<-USAGE
release-base-cr.sh [OPTIONS]

Publish into ECR_REGISTRY

OPTIONS
  --help  -h  prints the command usage
USAGE
}

function cmd::build() {

  : ${IMAGE_TAG:=debug}
  : ${ECR_REGISTRY:=docker.io}

  workspace=$1
  tag=$IMAGE_TAG

  readonly repository="laraboot/laravel-app"

  printf "  ----> Id: %s" $repository
  printf "  ----> Tag: %s" "$ECR_REGISTRY/$repository:$IMAGE_TAG"

  # use -b flag to specify base e.g busybox
  crane append -f <(tar -f - --directory=$workspace -c ./) -t $repository:$tag
}

main "${@:-}"
