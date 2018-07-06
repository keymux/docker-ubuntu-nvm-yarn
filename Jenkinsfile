def nvm = { e -> sh("/nvm.sh ${e}") }
def nvmTest = { e -> sh(script: "/nvm.sh ${e}", returnStatus: true ) }

def versions = ["6.10.2", "6", "7", "8.10", "8", "9", "10"]

def image = "keymux/docker-ubuntu-nvm-yarn"
def tag = "0.2.0-alpha.1"
def imageAndTag = "${image}:${tag}"

def dockerVols = [
  "/var/run/docker.sock",
  "/usr/bin/docker",
  "/usr/lib/x86_64-linux-gnu/libltdl.so.7"
].collect { "-v ${it}:${it}" }

// TODO: User and Group ID should be determined from the host here
def args = [
  "--entrypoint",
  "''",
  "-u 1000:999"
]

def dockerVolsArgs = dockerVols.join(' ')
def dockerArgs = args.join(' ')
def allDockerArgs = [dockerVolsArgs, dockerArgs].join(" ")

node("docker") {
  docker
    .image(imageAndTag)
    .inside(allDockerArgs)
  {
    checkout scm

    //def mapToSteps = { fn, list -> list.inject([:]) { m, v -> return m + [(v): { fn(v) }] } }
    def mapToSteps = load("src/build/map_to_steps.groovy")

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
      nvm("yarn install --frozen-lockfile")
    }

    stage ("Build") {
      nvm("yarn build")
    }

    stage ("Test Versions") {
      def fn = { version ->
        nvm("yarn test:version ${version}")
        nvm("yarn test:integration")
      }

      def steps = mapToSteps(fn, versions)

      parallel(steps)
    }

    stage ("Unit Tests") {
      def fn = { version ->
        def lArgs = "-v ${WORKSPACE}:${WORKSPACE}:ro -w ${WORKSPACE}"
        def cmd = "yarn test:unit"

        nvm("docker run ${lArgs} --rm ${imageAndTag} ${cmd}")
      }

      def steps = mapToSteps(fn, versions)

      parallel(steps)
    }

    stage ("Reporting") {
      reports = [
        "unit"
      ]

      parallel(mapToSteps({ r -> nvm("yarn report:${r}") }, reports))
    }

    stage ("Post report") {
      // If this is a pull request, submit a comment
      if (env.BRANCH_NAME =~ /^PR-/) {
        nvm("yarn submit:aggregate")
        nvm("yarn submit:comment")
      }
    }

    stage ("Validate Workflow") {
      nvm("yarn validate_workflow")
    }

    // If this is a new changeset on master
    if (env.BRANCH_NAME == "master") {
      stage ("Deploy master branch") {
        nvm("yarn prevent_clobber")

        nvm("yarn git_tag")

        nvm("yarn push")
      }
    }

    // If this is a new changeset on develop
    if (env.BRANCH_NAME == "develop" || env.BRANCH_NAME == "dev") {
      def wouldClobber = nvmTest("yarn prevent_clobber")

      if (wouldClobber == 0) {
        stage ("Deploy develop branch") {
          nvm("yarn git_tag")

          nvm("yarn push")
        }
      }
    }
  }
}
