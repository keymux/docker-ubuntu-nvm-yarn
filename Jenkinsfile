node("docker") {
  checkout scm

  def nvm = { e -> sh("/nvm.sh ${e}") }
  def nvmTest = { e -> sh(script: "/nvm.sh ${e}", returnStatus: true ) }

  def versions = ["6.10.2", "6", "7", "8.10", "8", "9", "10"]

  def image = "keymux/docker-ubuntu-nvm-yarn"
  def tag = "0.2.0-alpha.3"
  def imageAndTag = "${image}:${tag}"

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
    "-v ${env.HOME}/.cache/yarn:/.cache/yarn:rw",
    "-w ${env.WORKSPACE}",
  ].join(" ")

  def allDockerArgs = "${dockerInDockerVolsArgs} ${dockerInDockerArgs} ${dockerArgs}"

  //def url = CHANGE_URL.replaceAll('/[^/]+/[^/]+$', "")

  //properties([$class: 'GithubProjectProperty', displayName: '', projectUrlStr: url])

  docker
    .image(imageAndTag)
    .inside(allDockerArgs)
  {
    def mapToSteps = load("src/build/map_to_steps.groovy")
    //def postCommentFileCreator = load("src/build/post_comment_file_creator.groovy")

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
        nvm("yarn test:integration")
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
      reports = [
        "unit"
      ]

      if (env.BRANCH_NAME =~ /^PR-/) {
        reports << "deploy"
      }

      parallel(mapToSteps({ r -> nvm("yarn report:${r}") }, reports))
    }

    stage ("Post report") {
      // If this is a pull request, submit a comment
      if (env.BRANCH_NAME =~ /^PR-/) {
        def s = { x -> sh(x) }
        def g = { x -> githubPRComment(
          comment: githubPRMessage(content: "test ${x}"),
          errorHandler: statusOnPublisherError('UNSTABLE')
        )}

        nvm("yarn report:aggregate")

        withCredentials([string(credentialsId: "jenkins-hibes_github_access_token", variable: "GITHUB_ACCESS_TOKEN")]) {
          nvm("yarn submit:comment")

          //postCommentFileCreator(s, g)("reports/report.md")
        }
      }
    }

    stage ("Validate Workflow") {
      nvm("yarn validate_workflow")
    }

    stage ("Deploy") {
      // If current branch is master or dev or develop
      if (["master", "develop", "dev"].contains(env.BRANCH_NAME)) {
        def wouldClobber = nvmTest("yarn prevent_clobber")

        // and would not clobber an existing deployment, then deploy
        if (wouldClobber == 0) {
          sshagent (credentials: ['665675ba-3101-4c2b-9aad-f25e18698463']) {
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
