const path = require("path");

const { compareSemvers } = require("../src/compare_semvers");
const { listTagsPromise } = require("../src/docker/api");
const { promiseMap } = require("@keymux/promisr");

const pkg = require(path.resolve("package.json"));
const dockerImageName = pkg.name.replace(/^@/, "");

const checkParams = env => {
  ["markdownFile", "sourceBranch", "destinationBranch", "version"].forEach(
    ea => {
      if (!env[ea]) {
        throw new Error(`Missing ${ea}`);
      }
    }
  );

  return env;
};

const getSafeMessage = env =>
  `![Can deploy](https://images.keymux.org/octicons16/green/cloud-upload.png)\nIf this pull request is merged into \`${
    env.destinationBranch
  }\`, \`${env.version}\` will be deployed\n`;

const getUnsafeMessage = env =>
  `![Cannot deploy](https://images.keymux.org/fontawesome16/red/chain-broken.png)\nCannot deploy \`${
    env.version
  }\` upon merging into \`${
    env.destinationBranch
  }\` -- it would clobber an existing deployment\n`;

const reportDeploy = env =>
  Promise.resolve(
    Object.assign({}, env, {
      // The branch containing changes
      sourceBranch: env.CHANGE_BRANCH,
      // The branch to receive changes
      destinationBranch: env.CHANGE_TARGET,
      // The version number to compare
      version: env.OVERRIDE_VERSION_CHECK || pkg.version,
    })
  )
    .then(checkParams)
    .then(env =>
      promiseMap(
        Object.assign({}, env, {
          versions: listTagsPromise(dockerImageName),
        })
      )
    )
    .then(env =>
      Object.assign({}, env, {
        safe: compareSemvers(env.versions, env.version),
      })
    )
    .then(env =>
      Object.assign({}, env, {
        markdown: (env.safe ? getSafeMessage : getUnsafeMessage)(env),
        EXIT_CODE: 0,
      })
    )
    .catch(err => {
      if (err.EXIT_CODE) {
        return err;
      } else {
        console.error(err);

        return Object.assign({}, err, {
          EXIT_CODE: 127,
        });
      }
    });

module.exports = {
  reportDeploy,
};
