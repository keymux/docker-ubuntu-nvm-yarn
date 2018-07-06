node("docker") {
  stage ("Introspection") {
    sh("pwd")
    sh("env")
  }

  stage ("Build") {
    sh("scripts/build.sh")
  }

  stage ("Test") {
    sh("scripts/test.sh")
  }
}
