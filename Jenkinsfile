pipeline {
  agent {
    label "docker"
  }

  stages {
    stage("build") {
      steps {
        parallel (
          "build": { sh 'docker build -t $(cat package.json | jq ".name") .' }
        )
      }
    }
  }
}
