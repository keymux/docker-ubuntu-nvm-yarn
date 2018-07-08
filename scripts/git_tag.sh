#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"

. "${SCRIPTS_DIR}/lib.sh"

# User the root level known_hosts if it is present (i.e. in docker)
if [ -f "/known_hosts" ]; then
  KH="-o UserKnownHostsFile=/known_hosts"
fi

# Verify that we can push
TEST_AUTH_OUTPUT=$(echo x | ssh $KH git@github.com 2>&1)
if ! echo ${TEST_AUTH_OUTPUT} | grep "You've successfully authenticated"; then
  echo "Cannot authenticate with github" >&2
  echo "${TEST_AUTH_OUTPUT}" >&2

  exit -1
fi

v=$(cat "${ROOT_DIR}/package.json" | jq -r ".version")

case $@ in
  -f|--force)
    git tag -d "${v}" && git push origin ":${v}"
    ;;
esac

git tag $v && git push --tags
