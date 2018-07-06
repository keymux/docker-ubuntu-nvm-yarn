def call (fn, list) {
  return list.inject([:]) { m, v -> return m + [(v): { fn(v) }] }
}

return this;
