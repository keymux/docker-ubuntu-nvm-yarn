#!/bin/bash

. ${NVM} && \
  nvm use $(nvm ls | grep -oE "v[0-9\.]+") && \
  $@
