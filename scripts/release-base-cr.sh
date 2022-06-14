#!/usr/bin/env bash

set -eu
set -o pipefail

readonly PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=PROGDIR/.util/print.sh
source "${PROGDIR}/.util/print.sh"

function main() {
  
  local dir tag base

  : ${IMAGE_TAG:=debug}


  dir=$(pwd)
  tag=$IMAGE_TAG
  base=""

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
    
    --base | -b)
        base="$2"
        shift # past argument
        shift # past value
      ;;
    
    --tag | -t)
        tag="$2"
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

  cmd::build $dir $tag $base
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

  : ${ECR_REGISTRY:=docker.io}

  workspace=$1
  tag=$2
  debugTag="$tag-debug"
  base=""

  if [ "$#" -gt 3 ]; then
      echo "Illegal number of parameters"
  fi

  if [ "$#" -gt 2 ]; then
      base=$3
  fi

  readonly repository="laraboot/laravel-app"

  util::print::title "Releasing OCI artifacts"
  printf " ----> Id: %s \n" $repository
  printf " ----> Tag: %s \n" "$ECR_REGISTRY/$repository:$IMAGE_TAG"

  if test -z "$base" 
  then
    crane append -f <(tar -f - --directory=$workspace -c usr/src/app) -t $repository:$tag
  else
    printf " ----> Base: %s \n" $base
    # use -b flag to specify base e.g busybox
    crane append -b $base -f <(tar -f - --directory=$workspace -c usr/src/app) -t $repository:$tag
  fi

  # now flatten
  crane flatten laraboot/laravel-app:$debugTag -t $tag -v
}

main "${@:-}"
