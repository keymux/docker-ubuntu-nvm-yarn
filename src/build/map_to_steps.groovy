def mapToSteps = {
  fn, versions ->
    return versions.inject([:]) { m, version ->
      m + [(version): fn]
    }
}
