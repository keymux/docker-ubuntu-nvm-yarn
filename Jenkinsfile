node("docker") {
  stages {
    stage("build") {
      steps {
        sh("scripts/build.sh")
      }
    }

    stage("test") {
      steps {
        sh("scripts/test.sh")
      }
    }
  }
}
