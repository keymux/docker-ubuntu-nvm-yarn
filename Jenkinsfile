pipeline {
  agent docker

  stages {
    stage("build") {
      steps {
        parallel (
          "build": { sh 'docker build -t $(basename $(pwd))' }
        )
      }
    }
  }
}
