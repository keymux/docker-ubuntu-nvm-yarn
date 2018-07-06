const path = require("path");
const rp = require("request-promise");

const {
  createLogger,
  format: { combine, printf, timestamp },
  transports,
} = require("winston");

const { compareSemversCreator } = require("../src/compare_semvers");

const compareSemvers = compareSemversCreator(
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

const rpOptions = {
  headers: {
    Authorization: "None",
  },
  json: true,
  method: "GET",
  resolveWithFullResponse: true,
  uri: `https://registry.hub.docker.com/v2/repositories/${dockerImageName}/tags/`,
};

rp(rpOptions)
  .then(({ body: { results } }) =>
    Object.keys(results)
      .map(x => results[x].name)
      .filter(x => x !== "latest")
  )
  .then(versions => compareSemvers(versions, packageJsonVersion))
  .then(pass => process.exit(pass ? 0 : -1))
  .catch(err => {
    console.error(JSON.stringify(rpOptions, null, 2));

    console.error((err.error && JSON.stringify(err.error, null, 2)) || err);

    console.error(err.response.headers);

    process.exit(-1);
  });
