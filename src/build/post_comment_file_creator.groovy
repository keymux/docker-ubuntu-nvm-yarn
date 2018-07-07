def call(sh, githubPRComment) {
  return { filename ->
    githubPRComment(comment: sh(script: "cat ${filename}", returnStdout: true).trim())
  }
}

return this;
