#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"

. "${SCRIPTS_DIR}/lib.sh"

FORCE=0

case $@ in
  -f|--force)
    FORCE=1
    ;;
esac

main() {
  V=$(node -e 'console.log(require("./package.json").version);')
  I=${DOCKER_IMAGE_NAME}

  describe=$(git describe --tags --dirty)

  if ! node "${SCRIPTS_DIR}/prevent_clobber.js" && [ ${FORCE} -ne 1 ]; then
    echo "Refusing to clobber existing version $describe, try \`-f\` to override" >&2
  elif check_version $describe; then
    yarn build

    docker push ${I}:latest && \
      docker tag ${I} ${I}:${V} && \
      docker push ${I}:${V}
  else
    echo "Refusing to publish 'dirty' version $describe" >&2
  fi
}

check_version() {
  VERSION_REGEX='^[v]?[0-9]+\.[0-9]+\.[0-9]+$'
  VERSION_REGEX_PRERELEASE='^[v]?[0-9]+\.[0-9]+\.[0-9]+[-](alpha)|(beta)|(rc)\.[0-9]+$'

  if echo $1 | grep -E ${VERSION_REGEX} || echo $1 | grep -E ${VERSION_REGEX_PRERELEASE}; then
    echo clean
    return 0
  else
    echo dirty
    return 1
  fi
}

main $@
