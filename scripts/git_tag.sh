#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"

. "${SCRIPTS_DIR}/lib.sh"

# Verify that we can authenticate with github
TEST_AUTH_OUTPUT=$(echo x | ssh -vvv git@github.com 2>&1)
if ! echo ${TEST_AUTH_OUTPUT} | grep "You've successfully authenticated" > /dev/null; then
  echo "Cannot authenticate with github" >&2
  echo "${TEST_AUTH_OUTPUT}" >&2

  echo "Some introspection:" >&2
  set -x
  cat $HOME/.ssh/known_hosts >&2
  ls $HOME/.ssh >&2

  set +x

  exit -1
fi

v=$(cat "${ROOT_DIR}/package.json" | jq -r ".version")

case $@ in
  -f|--force)
    git tag -d "${v}" && git push origin ":${v}"
    ;;
esac

git tag $v && git push --tags
