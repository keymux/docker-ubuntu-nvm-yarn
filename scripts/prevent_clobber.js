const path = require("path");

const { listTagsPromise } = require("../src/docker/api");

const {
  createLogger,
  format: { combine, printf, timestamp },
  transports,
} = require("winston");

const { _compareSemversCreator } = require("../src/compare_semvers");

const compareSemvers = _compareSemversCreator(
  createLogger({
    format: combine(
      timestamp(),
      printf(i => `${i.timestamp} ${i.level}: ${i.message}`)
    ),
    level: process.env.LOG_LEVEL || "info",
    transports: [
      new transports.Console({
        stderrLevels: ["error", "warn", "info", "verbose", "debug", "silly"],
      }),
    ],
  })
);

const packageJson = require(path.resolve("package.json"));
const dockerImageName = packageJson.name.replace(/^@/, "");
const packageJsonVersion =
  process.env.OVERRIDE_VERSION_CHECK || packageJson.version;

listTagsPromise(dockerImageName)
  .then(versions => compareSemvers(versions, packageJsonVersion))
  .then(pass => process.exit(pass ? 0 : -1))
  .catch(err => {
    console.error((err.error && JSON.stringify(err.error, null, 2)) || err);

    console.error(err.response.headers);

    process.exit(127);
  });
