# Keymux docker-ubuntu-nvm-yarn

## Description

This repository contains build steps for building and deploying a docker container which mainly provides:
* Build tooling for Node projects
* NVM for selecting and installing arbitrary versions of Node
* Yarn as an alternative to NPM

## Build Status

Branch  | Status
------- | ------
Master  | [![Build Status](https://jenkins.keymux.org/buildStatus/icon?job=keymux/docker-ubuntu-nvm-yarn/master)](https://jenkins.keymux.org/job/keymux/job/docker-ubuntu-nvm-yarn/job/master/)
Develop | [![Build Status](https://jenkins.keymux.org/buildStatus/icon?job=keymux/docker-ubuntu-nvm-yarn/develop)](https://jenkins.keymux.org/job/keymux/job/docker-ubuntu-nvm-yarn/job/develop/)

## Build instructions:

### Jenkins Global Configuration

Using Jenkins, you can target the `Jenkinsfile` to automate building.  Some dependencies for Jenkins:
* Credentials:
  * `jenkins_github_https` should hold a username and password for github:
    * For removing the anonymous limitation on github API hits
  * `jenkins_github_access_token` must hold an API key for the github HTTPS API:
    * For posting github comments to PRs
  * `jenkins_github_ssh` must hold a private key which can be used to authenticate with github over SSH:
    * For pushing tags
    * For merging any new code changes on master into develop when necessary
  * `jenkins_docker_keymux_login` must hold a username and password to docker hub which permits modifications to the keymux/ namespace
    * For pushing docker images to docker hub

### Build Nodes

* You must have one or more build nodes which have docker installed
* For each of those nodes:
  * the user that Jenkins will use on that box must have access to the docker daemon
  * Only the docker socket (`/var/run/docker.sock`) is supported
  * x64 is required (because of `/usr/lib/x86_64-linux-gnu/libltdl.so.7`).  Probably other related impacts here, too.
  * The jenkins user must be `1001`, see `-u 1001:999` in Jenkinsfile and `ENV USERID 1001` in Dockerfile
  * The docker user group must be `999`, see: `-u 1001:999` in Jenkinsfile and `ENV DOCKERGID 999` in Dockerfile

### Job Configuration

You can do a number of different pipeline-based jobs here, but I'll only touch on the github Organization job.

* Projects
  * Credentials: `jenkins_github_https`
    * This is optional, but highly recommended for performance
  * Owner: `keymux` (or whomever)
  * Behaviours
    * Discover Branches
      * Strategy: `Exclude branches that are also filed as PRs`
    * Discover pull requests from origin
      * Strategy: `Merging the pull request with the current target branch revision`
    * Discover pull requests from forks
      * Strategy: `Merging the pull request with the current target branch revision`
      * Trust: `Nobody` (recommended because attackers could use your settings here to compromise your Jenkins server and/or nodes)
  * Advanced clone behaviours (Have to add this)
    * Fetch tags: `true`
  * Checkout over SSH (Have to add this)
    * Credentials: `jenkins_github_ssh`

* Project Recognizers
  * Pipeline Jenkinsfile
    * Script Path: `Jenkinsfile`

* Scan Organization Triggers
  * Periodically if not otherwise run: `true`
    * Interval: `1 hour` (or whatever)

* Orphaned Item Strategy
  * Discard old items: `true`

### From there...

You should have a working pipeline.

## Working locally

`yarn install` to pull dependencies, which are required for many steps.

### Build an image

These two commands are identical:
* `yarn build`
* `scripts/build.sh`

### Test a command, assuming a reliance on docker

Let's say I want to just print Hello World. (`yarn start` and `scripts/start.sh` may be used interchangeably here)

```
yarn start echo Hello World
```

Now what if I want to spin up a docker container inside that container?

WARNING: This will pull down the `hello-world` container from docker hub.

```
yarn start docker run hello-world
```

### Run Automated Tests

#### Unit Tests

`yarn test:unit`

#### End to End Integration Tests

`yarn test:e2e`

#### Test a Specific Node Version

`yarn test:version 6.10.2`

### Generated Automated Test Reports

#### All at Once

`yarn report:_all`

#### Generate the PR Comment

`yarn report:aggregate`

#### Preview the PR Comment

`yarn preview:comment`

#### Generate and Preview

`rm -rf reports && yarn report:_all && yarn report:aggregate && yarn preview:comment`

#### One at a Time

Report Name | Command
----------- | --------------------
deploy      | `yarn test:deploy`
unit        | `yarn test:unit`
coverage    | `yarn test:coverage`

#### Deploy

Deploy is an odd one since it expects certain environment variables.

```bash
# Be sure to set package.json's .version field to 0.1.0 first
CHANGE_BRANCH=release/v0.1.0 CHANGE_TARGET=master yarn report:deploy
# or add OVERRIDE_VERSION_CHECK=0.1.0
CHANGE_BRANCH=release/v0.1.0 CHANGE_TARGET=master OVERRIDE_VERSION_CHECK=0.1.0 yarn report:deploy
# Be sure to set package.json's .version field to 999.999.999 first
CHANGE_BRANCH=release/v999.999.999 CHANGE_TARGET=master yarn report:deploy
# or add OVERRIDE_VERSION_CHECK=999.999.999
CHANGE_BRANCH=release/v999.999.999 CHANGE_TARGET=master OVERRIDE_VERSION_CHECK=999.999.999 yarn report:deploy
```

### Push an image

`yarn push`
