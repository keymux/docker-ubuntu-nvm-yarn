node("docker") {
  checkout scm

  sh(". $HOME/.nvm/nvm.sh")

  stage ("Introspection") {
    sh("pwd")
    sh("env")
    sh("node -v")
    sh("yarn -v")
  }

  stage ("Dependencies") {
    sh("yarn")
  }

  stage ("Build") {
    sh("yarn build")
  }

  stage ("Test") {
    def versions = ["6.10.2", "6", "7", "8.10", "8", "9", "10"]

    def steps = versions.inject([:]) { m, version ->
      return m + [(version): {
        sh("scripts/test_version.sh " + version)
      }]
    }

    parallel(steps)
  }

  stage ("Check if Tag Exists") {
    sh("yarn prevent_clobber")
  }
}
