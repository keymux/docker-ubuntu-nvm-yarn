#!/bin/bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"

. "${SCRIPTS_DIR}/lib.sh"

set -x
docker run \
  -v "/var/run/docker.sock:/var/run/docker.sock:rw" \
  -v "/usr/bin/docker:/usr/bin/docker:ro" \
  -v "/usr/lib/x86_64-linux-gnu/libltdl.so.7:/usr/lib/x86_64-linux-gnu/libltdl.so.7:ro" \
  --rm "${DOCKER_IMAGE_NAME}" $@
