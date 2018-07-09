#!/usr/bin/env bash

# TODO: Move all of this js stuff into a node module
# Tests the binary file scripts/prevent_clobber.js

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
MY_DIR="${MY_DIR:?}"
SCRIPTS_DIR="$(realpath "${MY_DIR}/..")"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"
UNIT_DIR="${ROOT_DIR}/test/unit"
REPORTS_DIR="${ROOT_DIR}/reports"
COVERAGE_SUMMARY_JSON="${REPORTS_DIR}/coverage/coverage-summary.json"
MARKDOWN_FILE="${REPORTS_DIR}/coverage.md"

yarn nyc \
  --reporter=lcov \
  --reporter=json-summary \
  --report-dir="${REPORTS_DIR}/coverage" \
  mocha \
    --recursive \
    test/unit \
  && \
  nyc-markdown \
    --coverage_filename "${COVERAGE_SUMMARY_JSON}" \
    | tee -a "${MARKDOWN_FILE}"
