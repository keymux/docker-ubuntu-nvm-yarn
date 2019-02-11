const defaultLogger = {
  silly: () => null,
  debug: () => null,
  verbose: () => null,
  info: () => null,
  notice: () => null,
  warn: console.error,
  warning: console.error,
  error: console.error,
  crit: console.error,
  alert: console.error,
  emerg: console.error,
};

module.exports = {
  defaultLogger,
};
