#!/usr/bin/env bash

# TODO: Move all of this js stuff into a node module
# Tests the binary file scripts/prevent_clobber.js

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
MY_DIR="${MY_DIR:?}"
SCRIPTS_DIR="$(realpath "${MY_DIR}/..")"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"
UNIT_DIR="${ROOT_DIR}/test/unit"
REPORTS_DIR="${ROOT_DIR}/reports"

. "${SCRIPTS_DIR}/lib.sh"

buildNycrc | json_pp > "${ROOT_DIR}/.nycrc"

yarn nyc \
  --all \
  --reporter=lcov \
  --reporter=json-summary \
  --reporter=text \
  --report-dir="${REPORTS_DIR}/coverage" \
  mocha \
    --reporter-options reportDir="${REPORTS_DIR}/coverage" \
    "${UNIT_DIR}"
