const { validateWorkflow } = require("../src/validate_workflow.js");

validateWorkflow(process.env)
  .then(process.exit)
  .catch(err => {
    console.error(JSON.stringify(rpOptions, null, 2));

    console.error((err.error && JSON.stringify(err.error, null, 2)) || err);

    console.error(err.response.headers);

    process.exit(-1);
  });
