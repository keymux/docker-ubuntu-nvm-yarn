#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"

. "${SCRIPTS_DIR}/lib.sh"

docker run \
  -e "NODE_VERSION=${1}" \
  -v "${SCRIPTS_DIR}/test_entrypoint.sh:/test_entrypoint.sh:ro" \
  --entrypoint "/test_entrypoint.sh" \
  "${DOCKER_IMAGE_NAME}"
