#!/usr/bin/env bash

# Translates a github repository multi-branch pipeline to the old ghprbRequestBuilder
# for compatibility

export ghprbGhRepository=$(echo "${JOB_NAME}" | sed 's/\/[^/]*$//')
export ghprbPullId=$(echo "${JOB_NAME}" | grep -oE "[0-9]+$")

echo ${ghprbGhRepository}/issues/${ghprbPullId}

BODY_FILE=reports/report.md github_cli createAnIssueComment
