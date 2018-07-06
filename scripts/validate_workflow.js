const { BRANCH_NAME, CHANGE_BRANCH, CHANGE_TARGET } = process.env;

const masterBranch = new RegExp(/^master$/i);
const developBranch = new RegExp(/^(dev)|(develop)$/i);

const feature = new RegExp(/^feature\//);
const bugfix = new RegExp(/^bugfix\//);
const release = new RegExp(/^release\//);

const PR = new RegExp(/^PR-/);

const regexes = [feature, bugfix, release];

const noNeedToValidate = regexes.reduce(
  (acc, regex) => acc || regex.test(BRANCH_NAME),
  false
);

const quit = (code = -1) => process.exit(code);

const pass = () => {
  console.error("Passed workflow validation");
  quit(0);
};

const fail = () => {
  console.error("Failed workflow validation");
  console.error(
    JSON.stringify(
      {
        BRANCH_NAME,
        CHANGE_BRANCH,
        CHANGE_TARGET,
      },
      null,
      2
    )
  );
  quit();
};

if (noNeedToValidate) {
  console.error("Not a pull request -- no need to validate workflow");

  quit(0);
}

console.error("Need to validate");

if (!PR.test(BRANCH_NAME)) {
  console.error(`Unexpected branch name ${BRANCH_NAME}`);

  fail();
}

/**
 * Only allow release branches to merge to master
 */
if (masterBranch.test(CHANGE_TARGET)) {
  if (release.test(CHANGE_BRANCH)) {
    pass();
  } else {
    fail();
  }
}

/**
 * Only allow feature branches, bugfix branches, or master to merge to develop
 */
if (developBranch.test(CHANGE_TARGET)) {
  if (
    feature.test(CHANGE_BRANCH) ||
    bugfix.test(CHANGE_BRANCH) ||
    masterBranch.test(CHANGE_BRANCH)
  ) {
    pass();
  } else {
    fail();
  }
}
