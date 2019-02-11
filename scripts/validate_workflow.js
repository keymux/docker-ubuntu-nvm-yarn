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
  .then(({ EXIT_CODE }) => process.exit(EXIT_CODE));
