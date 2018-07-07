const rp = require("request-promise");

/**
 * Promises to list docker hub tags given a docker image name
 */
const listTagsPromise = dockerImageName => {
  const rpOptions = {
    headers: {
      Authorization: "None",
    },
    json: true,
    method: "GET",
    resolveWithFullResponse: true,
    uri: `https://registry.hub.docker.com/v2/repositories/${dockerImageName}/tags/`,
  };

  return rp(rpOptions).then(({ body: { results } }) =>
    Object.keys(results)
      .map(x => results[x].name)
      .filter(x => x !== "latest")
  );
};

module.exports = {
  listTagsPromise,
};
