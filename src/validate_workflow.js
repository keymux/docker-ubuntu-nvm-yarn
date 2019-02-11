const {
  _RETURN_CODES: { FAIL, FATAL, SUCCESS },
} = require("./return_codes");

const _validateWorkflowCreator = logger => env => {
  return new Promise(resolve => {
    const { BRANCH_NAME, CHANGE_BRANCH, CHANGE_TARGET } = env;

    const masterBranch = new RegExp(/^master$/i);
    const developBranch = new RegExp(/^(dev)|(develop)$/i);

    const feature = new RegExp(/^feature\//);
    const bugfix = new RegExp(/^bugfix\//);
    const release = new RegExp(/^release\//);

    const semver = new RegExp(/^[0-9]+\.[0-9]+\.[0-9]+$/);

    const PR = new RegExp(/^PR-/);

    const pass = () => {
      logger.error("Passed workflow validation");

      return resolve({ EXIT_CODE: SUCCESS });
    };

    const fail = () => {
      logger.error("Failed workflow validation");
      logger.error(
        JSON.stringify(
          {
            BRANCH_NAME,
            CHANGE_BRANCH,
            CHANGE_TARGET,
          },
          null,
          2
        )
      );

      return resolve({ EXIT_CODE: FAIL });
    };

    const noNeedToValidate = [
      feature,
      bugfix,
      release,
      masterBranch,
      developBranch,
    ].reduce((acc, regex) => acc || regex.test(BRANCH_NAME), false);

    if (noNeedToValidate) {
      logger.error("Not a pull request -- no need to validate workflow");

      return resolve({ EXIT_CODE: SUCCESS });
    }

    logger.error("Need to validate");

    if (masterBranch.test(CHANGE_TARGET)) {
      /**
       * Only allow release branches and develop to merge to master
       */
      if (release.test(CHANGE_BRANCH) || developBranch.test(CHANGE_BRANCH)) {
        return pass();
      } else {
        return fail();
      }
    } else if (developBranch.test(CHANGE_TARGET)) {
      /**
       * Only allow feature branches, bugfix branches, or master to merge to develop
       */
      if (
        feature.test(CHANGE_BRANCH) ||
        bugfix.test(CHANGE_BRANCH) ||
        masterBranch.test(CHANGE_BRANCH)
      ) {
        return pass();
      } else {
        return fail();
      }
    } else {
      if (!PR.test(BRANCH_NAME)) {
        return fail();
      } else {
        return pass();
      }
    }
  }).catch(err => {
    return Object.assign({}, err, { EXIT_CODE: FATAL });
  });
};

const validateWorkflow = _validateWorkflowCreator(console);

module.exports = {
  _validateWorkflowCreator,
  validateWorkflow,
};
