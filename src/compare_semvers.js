const semver = require("semver");

const { defaultLogger } = require("./default_logger");

/**
 * @return {boolean} - True if this deployment would be a new version, False if it would clobber
 */
const _compareSemversCreator = logger => (versions, version) => {
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

const compareSemvers = _compareSemversCreator(defaultLogger);

module.exports = {
  _compareSemversCreator,
  compareSemvers,
};
