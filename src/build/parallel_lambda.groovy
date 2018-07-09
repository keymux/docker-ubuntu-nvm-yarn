// Simulates Jenkins groovy parallel function for pipelines
def parallel = {
  m ->
    m.collect {
      k, v ->
        v(k)
    }
}

return parallel
