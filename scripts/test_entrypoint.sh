#!/usr/bin/env bash

env

. ${NVM} && \
  nvm install ${NODE_VERSION} && \
  nvm use ${NODE_VERSION} && \
  node -v
