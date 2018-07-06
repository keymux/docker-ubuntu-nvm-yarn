#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR=$(realpath "${SCRIPTS_DIR}/..")

whichOrExit() {
  if ! which $1; then
    echo "$1 must be installed" >&2

    return 1
  fi

  return 0
}

whichOrExit jq

DOCKER_IMAGE_NAME="$(cat "${ROOT_DIR}/package.json" | jq -r ".name")"
