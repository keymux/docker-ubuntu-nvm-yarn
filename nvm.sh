#!/bin/bash

. ${NVM}

if [ -z "${NODE_VERSION}" ]; then
  NODE_VERSION="$(nvm ls | grep -oE "v[0-9\.]+")"
else
  nvm install ${NODE_VERSION} > /dev/null
fi

nvm use ${NODE_VERSION} > /dev/null

"$@"
