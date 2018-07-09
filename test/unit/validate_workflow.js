const { expect } = require("chai");
const { spy } = require("sinon");

const uuid = require("uuid");

const { defaultLogger } = require("../../src/default_logger");
const {
  _RETURN_CODES: { FAIL, FATAL, SUCCESS },
} = require("../../src/return_codes");
const { _validateWorkflowCreator } = require("../../src/validate_workflow");

describe("validateWorkflow()", () => {
  let logger;

  const log = () =>
    JSON.stringify(
      Object.keys(logger).reduce(
        (a, x) =>
          Object.assign(
            {},
            a,
            !!logger[x] && logger[x].args.length > 0
              ? { [x]: logger[x].args }
              : {}
          ),
        {}
      ),
      null,
      2
    );

  beforeEach(() => {
    logger = Object.keys(defaultLogger).reduce(
      (a, key) => Object.assign({}, a, { [key]: spy() }),
      {}
    );
  });

  const newPRToBranchFixtureCreator = CHANGE_TARGET => (
    CHANGE_BRANCH,
    expected
  ) => {
    const BRANCH_NAME = `PR-${uuid()}`;
    const n = expected === SUCCESS ? "" : "not ";

    return {
      BRANCH_NAME,
      CHANGE_BRANCH,
      CHANGE_TARGET,
      expected,
      it: `should ${n}allow a pr to merge a branch like ${CHANGE_BRANCH} into ${CHANGE_TARGET}`,
    };
  };

  const newPRToMasterFixture = newPRToBranchFixtureCreator("master");
  const newPRToDevelopFixture = newPRToBranchFixtureCreator("develop");

  const noNeedToValidate = BRANCH_NAME => ({
    BRANCH_NAME,
    expected: SUCCESS,
    it: `should not need to validate ${BRANCH_NAME}`,
  });

  const fixtures = [
    // Allow develop and release branches to merge to master
    newPRToMasterFixture(`develop`, SUCCESS),
    newPRToMasterFixture(`release/${uuid()}`, SUCCESS),
    // Disallow bugfixes and feature branches from merging to master
    newPRToMasterFixture(`bugfix/${uuid()}`, FAIL),
    newPRToMasterFixture(`feature/${uuid()}`, FAIL),

    // Allow master, bugfixes, and feature branches to merge to develop
    newPRToDevelopFixture(`bugfix/${uuid()}`, SUCCESS),
    newPRToDevelopFixture(`feature/${uuid()}`, SUCCESS),
    // Disallow release branches from merging to develop
    newPRToDevelopFixture(`release/${uuid()}`, FAIL),

    // No need to validate if the base branch is not a pull request
    noNeedToValidate("bugfix/"),
    noNeedToValidate("feature/"),
    noNeedToValidate("release/"),
    noNeedToValidate("master"),
    noNeedToValidate("develop"),

    {
      BRANCH_NAME: "bugfix/",
      CHANGE_BRANCH: "bugfix/",
      CHANGE_TARGET: "bugfix/",
      expected: SUCCESS,
      it: "should default to SUCCESS if no constraints are hit",
    },

    {
      BRANCH_NAME: "bla",
      expected: FAIL,
      it: "should fail on a non-standard branch name",
    },
    {
      BRANCH_NAME: "PR-5",
      expected: SUCCESS,
      it: "should succeed if a PR isn't merging to master or develop",
    },
    {
      BRANCH_NAME: `PR-${uuid()}`,
      CHANGE_BRANCH: `bugfix/${uuid()}`,
      CHANGE_TARGET: "develop",
      expected: SUCCESS,
      it: "should allow a bugfix to merge into develop",
    },
    {
      BRANCH_NAME: `PR-uuid()`,
      CHANGE_BRANCH: `feature/${uuid()}`,
      CHANGE_TARGET: "develop",
      expected: SUCCESS,
      it: "should allow a feature to merge into develop",
    },
  ].map(fixture =>
    // Build the input from the variables
    Object.assign(fixture, {
      input: ({ BRANCH_NAME, CHANGE_BRANCH, CHANGE_TARGET } = fixture),
    })
  );

  fixtures.forEach(fixture =>
    it(fixture.it, () =>
      // Create and resolve the promise
      _validateWorkflowCreator(logger)(fixture.input).then(actual =>
        expect(actual.EXIT_CODE, `log: ${log()}`).to.deep.equal(
          fixture.expected
        )
      )
    )
  );

  it("should provide a fatal error code if an error interrupts processing", () => {
    _validateWorkflowCreator({})({}).then(({ EXIT_CODE }) =>
      expect(EXIT_CODE).to.equal(FATAL)
    );
  });
});
