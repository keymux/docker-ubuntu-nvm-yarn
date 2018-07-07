const { validateWorkflow } = require("../src/validate_workflow.js");

const { env } = process;
const { spawnSync } = require("child_process");

Promise.resolve(env)
  .then(env =>
    Object.assign(env, {
      DIRTY_TAG:
        env.DIRTY_TAG ||
        spawnSync("git", ["--dirty", "--tags", "--always"]).stdout.toString(),
    })
  )
  .then(validateWorkflow)
  .then(process.exit)
  .catch(err => {
    console.error(JSON.stringify(rpOptions, null, 2));

    console.error((err.error && JSON.stringify(err.error, null, 2)) || err);

    console.error(err.response.headers);

    process.exit(-1);
  });
