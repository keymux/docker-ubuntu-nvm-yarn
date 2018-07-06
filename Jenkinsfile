node("docker") {
  checkout scm

  stage ("Introspection") {
    sh("pwd")
    sh("env")
  }

  stage ("Build") {
    sh("scripts/build.sh")
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
}
