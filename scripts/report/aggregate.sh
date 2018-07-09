#!/usr/bin/env bash

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
MY_DIR="${MY_DIR:?}"
SCRIPTS_DIR="$(realpath "${MY_DIR}/..")"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"
REPORTS_DIR="${ROOT_DIR}/reports"
MARKDOWN_FILE="${REPORTS_DIR}/report.md"

. "${SCRIPTS_DIR}/lib.sh"

rm -f "${MARKDOWN_FILE}"

ls "${REPORTS_DIR}"

# The list of reports to run is contained in .reports of package.json
getReports | while read line; do
  if [ -f "${REPORTS_DIR}/${line}.md" ]; then
    echo "## $(basename "${line}")" | sed 's/\.md$//'

    cat "${REPORTS_DIR}/${line}.md"
  fi
done | tee "${MARKDOWN_FILE}"
