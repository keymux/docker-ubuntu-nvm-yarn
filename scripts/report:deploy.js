const path = require("path");

const { reportDeploy } = require("../src/report_deploy");

const { promiseMap } = require("@keymux/promisr");
const { writeFilePromise } = require("@keymux/promisrfs");

const main = env =>
  Promise.resolve(
    Object.assign({}, process.env, {
      // The markdown file to be written
      markdownFile:
        env.MARKDOWN_FILE || path.resolve("reports/report:deploy.md"),
    })
  )
    .then(reportDeploy)
    .then(env =>
      promiseMap(
        Object.assign({}, env, {
          write: writeFilePromise(env.markdownFile, env.markdown),
        })
      )
    )
    .then(env => process.exit(env.EXIT_CODE))
    .catch(err => {
      console.error(err);

      process.exit(127);
    });

main(process.env);
