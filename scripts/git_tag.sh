#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"

. "${SCRIPTS_DIR}/lib.sh"

v=$(cat "${ROOT_DIR}/package.json" | jq -r ".version")

case $@ in
  -f|--force)
    git tag -d "${v}" && git push origin ":${v}"
    ;;
esac

git tag $v
