#!/usr/bin/env bash

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
MY_DIR="${MY_DIR:?}"
SCRIPTS_DIR="$(realpath "${MY_DIR}/..")"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"

. "${SCRIPTS_DIR}/lib.sh"

# The list of reports to run is contained in .reports of package.json
getReports | while read line; do
  yarn report:$line
done
