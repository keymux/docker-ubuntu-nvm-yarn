const { validateWorkflow } = require("../src/validate_workflow.js");

const { env } = process;
const { spawnSync } = require("child_process");

// TODO: Not sure where this would be useful, but not here
// Jenkins won't have tagged by the time this would run
const appendDirtyTag = env =>
  Object.assign(env, {
    DIRTY_TAG:
      env.DIRTY_TAG ||
      spawnSync("git", ["--dirty", "--tags", "--always"]).stdout.toString(),
  });

Promise.resolve(env)
  .then(validateWorkflow)
  .then(process.exit)
  .catch(err => {
    console.error(JSON.stringify(rpOptions, null, 2));

    console.error((err.error && JSON.stringify(err.error, null, 2)) || err);

    console.error(err.response.headers);

    process.exit(-1);
  });
