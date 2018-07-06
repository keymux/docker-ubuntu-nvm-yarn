#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR=$(realpath "${SCRIPTS_DIR}/..")

. "${SCRIPTS_DIR}/lib.sh"

test_version() {
  version="$(docker run -e "NODE_VERSION=${1}" -v "${SCRIPTS_DIR}/test_entrypoint.sh:/test_entrypoint.sh:ro" --entrypoint "/test_entrypoint.sh" "${DOCKER_IMAGE_NAME}")"

  if echo "$version" | grep -E "^[v]?${1}"; then
    return 0
  fi

  echo "${version} was not the expected output" >&2

  return -1
}

count=0

for i in 6 6.10.2 7 8 8.10 9 10; do
  test_version $i || (echo "Failed $i" >&2 && let count=${count}+1)
done

if [ ${count} -gt 0 ]; then
  echo "Counted ${count} failures" >&2
  exit -1
fi
