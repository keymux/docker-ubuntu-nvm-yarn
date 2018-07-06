#!/usr/bin/env bash

# TODO: Move all of this js stuff into a node module
# Tests the binary file scripts/prevent_clobber.js

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR=$(realpath "${SCRIPTS_DIR}/..")
P_CLOB="${SCRIPTS_DIR}/prevent_clobber.js"

. "${SCRIPTS_DIR}/lib.sh"

export DEBUG_LOGGING=1

# Tests that should pass
for i in "999.999.999" "999.999.999-ZZZ.999"; do
  export OVERRIDE_VERSION_CHECK="$i"

    if ! node "${P_CLOB}"; then
      echo "Failed ${OVERRIDE_VERSION_CHECK}"

      exit -1
    fi
  done

  # Tests that should fail
  for i in "0.0.0" "0.0.1" "0.1.0-alpha.1"; do
    export OVERRIDE_VERSION_CHECK="$i"

    if node "${P_CLOB}"; then
    echo "Failed ${OVERRIDE_VERSION_CHECK}"

    exit -1
  fi
done

export DEBUG_LOGGING=
