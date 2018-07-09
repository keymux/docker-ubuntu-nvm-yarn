//def mapToSteps = evaluate(new File("src/build/map_to_steps.groovy"))
def load = { x -> evaluate(new File(x)) }

def mapToSteps = load("src/build/map_to_steps.groovy")

// Print, assert, then return the result
def pAssert = {
  cond ->
    println(cond)

    assert(cond)

    return cond
}

def process = {
  version ->
    return version
}

def parallel = load("src/build/parallel_lambda.groovy")

def nvm = {
  cmd -> "/nvm ${cmd * 3}"
}

def fixtures = [
  [
    input: ["1234", "5678"],
    expected: ["1234", "5678"],
    fn: process,
  ],
  [
    input: [2, 4, 6, 8, 10],
    expected: [4, 8, 12, 16, 20],
    fn: { x -> x * 2 },
  ],
  [
    input: [1, 3, 5, 7, 9],
    expected: ["/nvm 3", "/nvm 9", "/nvm 15", "/nvm 21", "/nvm 27"],
    fn: { cmd -> nvm(cmd) },
  ],
].collect({ x ->
  x.actual = parallel(mapToSteps(x.fn, x.input))

  return x
})

fixtures.collect { fixture -> pAssert(fixture.actual == fixture.expected) }
