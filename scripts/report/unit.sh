#!/usr/bin/env bash

# TODO: Move all of this js stuff into a node module
# Tests the binary file scripts/prevent_clobber.js

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
MY_DIR="${MY_DIR:?}"
SCRIPTS_DIR="$(realpath "${MY_DIR}/..")"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"
UNIT_DIR="${ROOT_DIR}/test/unit"
REPORTS_DIR="${ROOT_DIR}/reports"
MOCHAWESOME_JSON="${REPORTS_DIR}/unit/mochawesome.json"
MARKDOWN_FILE="${REPORTS_DIR}/unit.md"

yarn mocha \
  --recursive \
  --reporter=mochawesome \
  --reporter-options "reportDir=${REPORTS_DIR}/unit" \
  "${UNIT_DIR}" \
  && \
yarn -s mochawesome_to_markdown \
  --mochawesome "${MOCHAWESOME_JSON}" \
  | tee -a ${MARKDOWN_FILE}
