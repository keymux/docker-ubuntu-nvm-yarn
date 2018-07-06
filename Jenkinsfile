def nvm = { e -> sh("/nvm.sh ${e}") }
def nvmTest = { e -> sh(script: "/nvm.sh ${e}", returnStatus: true ) }

def mapToSteps = evaluate(new File("src/build/map_to_steps.groovy"))

def versions = ["6.10.2", "6", "7", "8.10", "8", "9", "10"]

def image = "keymux/docker-ubuntu-nvm-yarn"
def tag = "0.2.0-alpha.1"
def imageAndTag = "${image}:${tag}"

def dockerVols = [
  "/var/run/docker.sock",
  "/usr/bin/docker",
  "/usr/lib/x86_64-linux-gnu/libltdl.so.7"
].collect { "${it}:${it}" }

// TODO: User and Group ID should be determined from the host here
def args = [
  "--entrypoint=''",
  "-u 1000:999"
]

def dockerVolsArgs = "${dockerVols.join(' ')} ${args.join(' ')}"
def dockerArgs = "${args.join(' ')}"
def allDockerArgs = [${dockerVolsArgs}, ${dockerArgs}].join(" ")

node("docker") {
  docker
    .image(imageAndTag)
    .inside(allDockerArgs)
  {
    checkout scm

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
      nvm("yarn")
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
        docker.image(imageAndTag).inside(dockerArgs) {
          nvm("yarn test:unit")
        }
      }

      def steps = mapToSteps(fn, versions)

      parallel(steps)
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
