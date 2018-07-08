const path = require("path");

const { reportDeploy } = require("../src/report_deploy");

const { promiseMap } = require("@keymux/promisr");
const { writeFilePromise } = require("@keymux/promisrfs");

const formatImageMd = (message, image) => `![${message}](${image})`;

const SAFE_IMAGE =
  "https://images.keymux.org/octicons32/green/cloud-upload.png";

const UNSAFE_IMAGE =
  "https://images.keymux.org/fontawesome32/red/chain-broken.png";

const main = env =>
  Promise.resolve(
    Object.assign({}, process.env, {
      // The markdown file to be written
      safeImageTag: formatImageMd("Can deploy", SAFE_IMAGE),
      unsafeImageTag: formatImageMd("Cannot deploy", UNSAFE_IMAGE),
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
