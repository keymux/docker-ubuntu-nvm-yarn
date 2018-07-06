def mapToSteps = evaluate(new File("src/build/map_to_steps.groovy"))

def process = {
  version ->
    return version
};

// Simulates Jenkins groovy parallel function for pipelines
def parallel = {
  m ->
    m.collect {
      k, v ->
        v(k)
    }
};

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
].collect({ x ->
  x.actual = parallel(mapToSteps(x.fn, x.input))

  return x
})

fixtures.collect { fixture -> assert fixture.actual == fixture.expected }
