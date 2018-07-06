def nvm = {
  e -> sh("/nvm.sh " + e)
}

node("docker") {
  docker.image("keymux/docker-ubuntu-nvm-yarn:0.2.0-alpha.1").inside("--entrypoint=''") {
    checkout scm

    stage ("Introspection") {
      nvm("pwd")
      nvm("env")
      nvm("node -v")
      nvm("yarn -v")
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
