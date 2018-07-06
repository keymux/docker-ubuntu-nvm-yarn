const path = require("path");
const rp = require("request-promise");
const semver = require("semver");

const packageJson = require(path.resolve("package.json"));
const dockerImageName = packageJson.name.replace(/^@/, "");
const packageJsonVersion = packageJson.version;

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
  .then(versions => {
    const willNotClobber = versions.reduce(
      (acc, version) => acc && semver.gt(packageJsonVersion, version),
      true
    );

    if (willNotClobber) {
      console.error(
        `${packageJsonVersion} was greater than all of ${JSON.stringify(
          versions
        )}`
      );
    } else {
      console.error(
        `${packageJsonVersion} is not safe because it is not greater than one of ${JSON.stringify(
          versions
        )}`
      );

      process.exit(-2);
    }
  })
  .catch(err => {
    console.error(JSON.stringify(rpOptions, null, 2));

    console.error((err.error && JSON.stringify(err.error, null, 2)) || err);

    console.error(err.response.headers);

    process.exit(-1);
  });
