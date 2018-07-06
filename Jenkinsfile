node("docker") {
  docker.image("keymux/docker-ubuntu-nvm-yarn:0.2.0-alpha.1").inside("-v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker:ro -v /usr/lib/x86_64-linux-gnu/libltdl.so.7:/usr/lib/x86_64-linux-gnu/libltdl.so.7:ro --entrypoint='' -u 1000:999") {
    def nvm = {
      e -> sh("/nvm.sh " + e)
    }

    checkout scm

    stage ("Introspection") {
      def cmds = [
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

      def steps = cmds.inject([:]) { m, cmd ->
        return m + [(cmd): {
          sh("/nvm.sh " + cmd)
        }]
      }

      parallel(steps)
    }

    stage ("Dependencies") {
      nvm("yarn")
    }

    stage ("Build") {
      nvm("yarn build")
    }

    stage ("Test") {
      def versions = ["6.10.2", "6", "7", "8.10", "8", "9", "10"]

      def steps = versions.inject([:]) { m, version ->
        return m + [(version): {
          nvm("scripts/test_version.sh " + version)
        }]
      }

      parallel(steps)
    }

    stage ("Check if Tag Exists") {
      nvm("yarn prevent_clobber")
    }
  }
}
