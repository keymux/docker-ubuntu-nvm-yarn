#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"

whichOrExit() {
  if ! which $1 > /dev/null 2>&1; then
    echo "$1 must be installed" >&2

    return 1
  fi

  return 0
}

uuid() {
  cmd="node -p 'require(\"uuid\")()'"

  if ! eval ${cmd}; then
    yarn global add uuid

    ${cmd}
  fi
}

assertFileEquals() {
  FILE="$1"
  CONTENTS="$2"

  diff "${FILE}" <(echo "${CONTENTS}")
}

assertGrep() {
  result=$(grep $@ 2>&1)

  if [ ${CODE} -ne 0 ]; then
    echo grep "$@"
    echo "resulted in:"
    echo "${result}"

    exit ${CODE}
  fi
}

whichOrExit yarn
whichOrExit jq

DOCKER_IMAGE_NAME="$(cat "${ROOT_DIR}/package.json" | jq -r ".name" | sed 's/^@//')"
