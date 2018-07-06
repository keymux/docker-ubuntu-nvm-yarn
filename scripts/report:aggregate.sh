#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"
REPORTS_DIR="${ROOT_DIR}/reports"
MARKDOWN_FILE="${REPORTS_DIR}/report.md"

. "${SCRIPTS_DIR}/lib.sh"

rm -f "${MARKDOWN_FILE}"

ls "${REPORTS_DIR}"/*.md | while read line; do
  echo "## $(basename "${line}")" | sed 's/\.md$//'

  cat "${line}"
done | tee "${MARKDOWN_FILE}"
