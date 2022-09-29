#!/usr/bin/env bash

set -eu
set -o pipefail

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=PROGDIR/.util/print.sh
source "${PROGDIR}/.util/print.sh"

function main() {
  while [[ "${#}" != 0 ]]; do
    case "${1}" in
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

  cmd::build
}

function usage() {
  cat <<-USAGE
release-build-cr.sh [OPTIONS]

Publish into ECR_REGISTRY

OPTIONS
  --help  -h  prints the command usage
USAGE
}

function cmd::build() {

  : ${IMAGE_TAG:=dev}

  readonly repository="laraboot/laravel"

  printf "  ----> Id: %s" $repository
  printf "  ----> Tag: %s" "$ECR_REGISTRY/$repository:$IMAGE_TAG"

  docker tag $LOCAL_IMAGE $ECR_REGISTRY/$repository:$IMAGE_TAG
  docker push $ECR_REGISTRY/$repository:"$IMAGE_TAG"
}

main "${@:-}"
