const semver = require("semver");

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

const compareSemversCreator = logger => (versions, version) => {
  logger.debug(`Comparing ${version} with ${JSON.stringify(versions)}`);

  return versions.reduce((acc, v, index) => {
    const result = semver.gt(version, versions[index]);

    if (result) {
      logger.debug(`${version} was greater than ${versions[index]}`);
    } else {
      (logger.warn || logger.warning)(
        `${version} was not greater than ${versions[index]}`
      );
    }

    return acc && result;
  }, true);
};

const compareSemvers = compareSemversCreator(defaultLogger);

module.exports = {
  compareSemversCreator,
  compareSemvers,
};
