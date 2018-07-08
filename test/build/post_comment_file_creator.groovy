def load = { x -> evaluate(new File(x)) }

def postCommentFileCreator = load("src/build/post_comment_file_creator.groovy")

def sh(m) {
  println("6 ${m}")

  return "example_markdown"
}

def githubPRComment(m) {
  println("12 ${m}")

  return "would have posted: ${m}"
}

def githubPRMessage(m) {
  println("18 ${m}")

  return "${m.comment}"
}

def s = { m -> sh(m) }

def g = { m -> githubPRComment(githubPRMessage(m)) }

/*
def sh = { m ->
  println(m)

  return "example_markdown"
}
*/

def postCommentFile = postCommentFileCreator(s, g)
println()
println()
println(postCommentFileCreator)
println(postCommentFile)
println()
println(postCommentFile("x"))
println()
println()

def thing = [comment: [content: "x"]]

println(thing.comment.content)
