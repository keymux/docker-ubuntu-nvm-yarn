pipeline {
  agent docker

  stages {
    stage("build") {
      steps {
        parallel (
          sh 'docker build -t $(basename $(pwd))'
        )
      }
    }
  }
}
