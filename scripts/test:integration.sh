#!/usr/bin/env bash

# TODO: Move all of this js stuff into a node module
# Tests the binary file scripts/prevent_clobber.js

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
SCRIPTS_DIR="${SCRIPTS_DIR:?}"
ROOT_DIR="$(realpath "${SCRIPTS_DIR}/..")"
P_CLOB="${SCRIPTS_DIR}/prevent_clobber.js"
V_WKFLOW="${SCRIPTS_DIR}/validate_workflow.js"

. "${SCRIPTS_DIR}/lib.sh"

export DEBUG_LOGGING=1

testPClob() {
  export OVERRIDE_VERSION_CHECK=$1

  result=$(node "${P_CLOB}" 2>&1)
  CODE=$?

  if [ ${CODE} -ne ${2} ]; then
    echo "Failed ${OVERRIDE_VERSION_CHECK}" >&2

    echo "Logged: ${result}" >&2

    exit -1
  fi
}

testValidateWorkflow() {
  export BRANCH_NAME=$1
  export CHANGE_BRANCH=$2
  export CHANGE_TARGET=$3
  export DIRTY_TAG=$4
  export EXP_CODE=$5

  result=$(node "${V_WKFLOW}" 2>&1)
  CODE=$?

  if [ ${CODE} -ne ${EXP_CODE} ]; then
    echo "Failed test with exit ${CODE} -- expected ${EXP_CODE} given args $@" >&2

    echo "Logged: ${result}" >&2

    exit -1
  fi
}

# Tests that should pass
for i in "999.999.999" "999.999.999-ZZZ.999"; do
  testPClob $i 0
done

# Tests that should fail
for i in "0.0.0" "0.0.1" "0.1.0-alpha.1"; do
  testPClob $i 255
done

# to develop
BRANCH=develop
TAG="0.2.0"
# PR
testValidateWorkflow "PR-1" "bugfix/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "PR-2" "feature/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "PR-3" "master" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "PR-4" "release/1" "${BRANCH}" "${TAG}" 255
# Not a PR
testValidateWorkflow "bugfix/1" "bugfix/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "feature/1" "feature/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "release/1" "release/1" "${BRANCH}" "${TAG}" 0

# to master
BRANCH=master
# Tag tests
TAG="0.2.0-dirty"
testValidateWorkflow "PR-5" "release/1" "${BRANCH}" "${TAG}" 255
TAG="0.2.0-alpha.1"
testValidateWorkflow "PR-6" "release/1" "${BRANCH}" "${TAG}" 255
TAG="0.2.0-"
testValidateWorkflow "PR-7" "release/1" "${BRANCH}" "${TAG}" 255
TAG="0.2.0"
testValidateWorkflow "PR-8" "release/1" "${BRANCH}" "${TAG}" 0

# PR
testValidateWorkflow "PR-9" "bugfix/1" "${BRANCH}" "${TAG}" 255
testValidateWorkflow "PR-10" "develop" "${BRANCH}" "${TAG}" 255
testValidateWorkflow "PR-11" "feature/1" "${BRANCH}" "${TAG}" 255
testValidateWorkflow "PR-12" "release/1" "${BRANCH}" "${TAG}" 0

# Not a PR
testValidateWorkflow "bugfix/1" "bugfix/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "feature/1" "feature/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "release/1" "release/1" "${BRANCH}" "${TAG}" 0

# to release branch
BRANCH=release/9
testValidateWorkflow "bugfix/1" "bugfix/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "feature/1" "feature/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "release/1" "release/1" "${BRANCH}" "${TAG}" 0

# to feature branch
BRANCH=feature/9
testValidateWorkflow "bugfix/1" "bugfix/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "feature/1" "feature/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "release/1" "release/1" "${BRANCH}" "${TAG}" 0

# to bugfix branch
BRANCH=bugfix/9
testValidateWorkflow "bugfix/1" "bugfix/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "feature/1" "feature/1" "${BRANCH}" "${TAG}" 0
testValidateWorkflow "release/1" "release/1" "${BRANCH}" "${TAG}" 0

export DEBUG_LOGGING=
