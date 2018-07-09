import groovy.json.JsonSlurper

node("docker") {
  checkout scm

  def jsonParser = new JsonSlurper();
  def packageJsonContents = sh(script: "cat package.json", returnStdout: true)
  def packageJson = jsonParser.parseText(packageJsonContents)

  def nvm = { e -> sh("/nvm.sh ${e}") }
  def nvmTest = { e -> sh(script: "/nvm.sh ${e}", returnStatus: true ) }

  def versions = ["6.10.2", "6", "7", "8.10", "8", "9", "10"]

  def image = "keymux/docker-ubuntu-nvm-yarn"
  def tag = "0.2.0-alpha.3"
  def imageAndTag = "${image}:${tag}"

  def yarnCache = "${env.HOME}/.cache/yarn"

  sh("mkdir -p ${yarnCache}")

  def dockerInDockerVolsArgs = [
    "/var/run/docker.sock",
    "/usr/bin/docker",
    "/usr/lib/x86_64-linux-gnu/libltdl.so.7",
  ].collect { "-v ${it}:${it}" }.join(" ")

  // TODO: User and Group ID should be determined from the host here
  def dockerInDockerArgs = [
    "--entrypoint",
    "''",
    "-u 1001:999",
    "-v ${env.WORKSPACE}/config/.ssh:/usr/local/nvm/.ssh:rw,z",
  ].join(" ")

  def dockerArgs = [
    "-v ${yarnCache}:/.cache/yarn:rw",
    "-w ${env.WORKSPACE}",
  ].join(" ")

  def allDockerArgs = "${dockerInDockerVolsArgs} ${dockerInDockerArgs} ${dockerArgs}"

  docker
    .image(imageAndTag)
    .inside(allDockerArgs)
  {
    def mapToSteps = load("src/build/map_to_steps.groovy")

    stage ("Clean") {
      nvm("git clean -xdf")
    }

    stage ("Introspection") {
      def cmds = [
        "env",
        "pwd",
        "node -v",
        "yarn -v",
        "id -u",
        "id -g",
        "groups",
        "cat /etc/group",
        "cat /etc/passwd",
        "ls -al /var/run/docker.sock",
        "id"
      ]

      def steps = mapToSteps({ cmd -> nvm(cmd) }, cmds)

      parallel(steps)
    }

    stage ("Dependencies") {
      nvm("yarn install --frozen-lockfile --prefer-offline")
      nvm("mkdir -p reports")
    }

    stage ("Build") {
      nvm("yarn build")
    }

    stage ("Integration Tests") {
      def fn = { version ->
        nvm("yarn test:version ${version}")
        nvm("yarn test:e2e")
      }

      def steps = mapToSteps(fn, versions)

      parallel(steps)
    }

    stage ("Unit Tests") {
      def fn = { version ->
        def cmd = "yarn test:unit"

        def lArgs = [
          "-v ${env.WORKSPACE}:${env.WORKSPACE}:ro",
          "${dockerArgs}",
          "--rm",
          "${imageAndTag}",
          "${cmd}"
        ].join(" ")


        nvm("docker run ${lArgs}")
      }

      def steps = mapToSteps(fn, versions)

      parallel(steps)
    }

    stage ("Reporting") {
      // The list of reports to run is contained in .reports of package.json
      reports = packageJson.reports

      parallel(mapToSteps({ r -> nvm("yarn report:${r}") }, reports))
    }

    // If this is a pull request, submit a comment
    if (env.BRANCH_NAME =~ /^PR-/) {
      stage ("Post report") {
        nvm("yarn report:aggregate")

        withCredentials([string(credentialsId: "jenkins_github_access_token", variable: "GITHUB_ACCESS_TOKEN")]) {
          nvm("yarn submit:comment")
        }
      }
    }

    stage ("Validate Workflow") {
      // Checks for things like (and prevents by failing builds)
      //  - pull requests trying to merge release branches into develop
      //  - pull requests trying to merge features or bugfixes into master
      nvm("yarn validate_workflow")
    }

    stage ("Deploy") {
      // If current branch is master or dev or develop
      if (["master", "develop", "dev"].contains(env.BRANCH_NAME)) {
        def wouldClobber = nvmTest("yarn prevent_clobber")

        // and would not clobber an existing deployment, then deploy
        if (wouldClobber == 0) {
          sshagent (credentials: ["jenkins_github_ssh"]) {
            nvm("yarn git_tag")
          }

          withDockerRegistry([credentialsId: "docker-keymux"]) {
            nvm("yarn push")
          }
        } else {
          echo("Nothing to do")
        }
      }
    }
  }
}
