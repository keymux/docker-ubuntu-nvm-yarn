#!/bin/bash

as_root() {
  if [ "${OVERRIDE_UID}" = "0" ] || [ "${OVERRIDE_GID}" = "0" ]; then
    # Probably don't ever want to allow overriding to the root user or group
    exit -1
  fi

  if [ -n "${OVERRIDE_UID}" ]; then
    usermod -u "${OVERRIDE_UID}" "${WORKING_USER}"
  fi

  if [ -n "${OVERRIDE_GID}" ]; then
    groupmod -g "${OVERRIDE_GID}" "${WORKING_GROUP}"
  fi
}

as_user() {
  . ${NVM}

  if [ -z "${NODE_VERSION}" ]; then
    NODE_VERSION="$(nvm ls | grep -oE "v[0-9\.]+")"
  else
    nvm install ${NODE_VERSION} > /dev/null
  fi

  nvm use ${NODE_VERSION} > /dev/null

  npm install -g yarn

  eval "$@"
}

if [ "${UID}" = "0" ]; then
  as_root "$@"

  set -x

  ARGS=""

  for i in "$@"; do
    ARGS="${ARGS} \"${i}\""
  done

  su "${WORKING_USER}" -c "${BASH_SOURCE[0]} ${ARGS}"
else
  as_user "$@"
fi
