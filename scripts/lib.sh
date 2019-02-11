#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"

whichOrExit() {
  if ! which $1 > /dev/null 2>&1; then
    echo "$1 must be installed" >&2

    return 1
  fi

  return 0
}

uuid() {
  cmd="node -p 'require(\"uuid\")()'"

  if ! eval ${cmd}; then
    yarn global add uuid

    ${cmd}
  fi
}

assertFileEquals() {
  FILE="$1"
  CONTENTS="$2"

  diff "${FILE}" <(echo "${CONTENTS}")
}

assertGrep() {
  result=$(grep $@ 2>&1)

  if [ ${CODE} -ne 0 ]; then
    echo grep "$@"
    echo "resulted in:"
    echo "${result}"

    exit ${CODE}
  fi
}

# The list of reports to run is contained in .reports of package.json
getReports() {
  cat "${ROOT_DIR}/package.json" | jq -r '.reports[]'
}

# Since I just want to ignore the contents of .gitignore, I'll generate
# the .nycrc file here
buildNycrc() {
  first=1
  echo -ne "{\"exclude\":["

  cat "${ROOT_DIR}/.gitignore" | grep -v '^!' | while read line; do
    if [ ${first} -eq 1 ]; then
      first=0
    else
      echo -ne ","
    fi

    echo -ne "\"${line}\""
  done

  echo -ne "]}\n"
}

detectOs() {
  u=${1}

  if [[ "${u}" == "Linux" ]]; then
    return 0
  elif [[ "${u}" == "FreeBSD" ]]; then
    return 1
  elif [[ "${u}" == "Darwin" ]]; then
    return 2
  elif [[ "${u}" == "Cygwin" ]]; then
    return 3
  else
    return 4
  fi
}

open() {
  uname=$(uname)
  detectOs "${uname}"
  os=$?

  case $os in
    0)
      xdg-open $@
      ;;
    2)
      open $@
      ;;
    3)
      cygstart $@
      ;;
    *)
      echo "Not sure how to handle this os (${uname})" >&2
      ;;
  esac
}

whichOrExit yarn
whichOrExit jq

DOCKER_IMAGE_NAME="$(cat "${ROOT_DIR}/package.json" | jq -r ".name" | sed 's/^@//')"
