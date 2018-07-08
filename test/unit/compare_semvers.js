const { expect } = require("chai");

const { compareSemvers } = require("../../src/compare_semvers.js");

describe("compareSemvers()", () => {
  const fixtures = [
    {
      input: [["0.1.0", "0.2.0"], "0.2.0"],
      expected: false,
      it: "should detect a version equal to a previous one as a failure",
    },
    {
      input: [["0.1.0", "0.2.0"], "0.2.0-alpha"],
      expected: false,
      it:
        "should detect an alpha version as less than an equivalent release version",
    },
    {
      input: [["0.1.0", "0.2.0-alpha"], "0.2.0-alpha.1"],
      expected: true,
      it:
        "should detect a new alpha version as greater than an equivalent release version",
    },
    {
      input: [["0.1.0", "0.2.0-alpha.1"], "0.2.0-alpha.1"],
      expected: false,
      it:
        "should detect a same alpha version as not greater than an equivalent release version",
    },
    {
      input: [["0.1.0", "0.2.0-alpha.2"], "0.2.0-alpha.1"],
      expected: false,
      it:
        "should detect a old alpha version as less than an equivalent release version",
    },
    {
      input: [["0.1.0", "0.2.0-alpha.1"], "0.2.0-alpha.2"],
      expected: true,
      it:
        "should detect a new alpha version as greater than an equivalent release version",
    },
    {
      /*Note the ampha in the input set here vs the alpha in the input version*/
      input: [["0.1.0", "0.2.0-ampha.1"], "0.2.0-alpha.2"],
      expected: false,
      it: "should be alphabetical after the -",
    },
    {
      input: [["0.1.0", "0.2.0-alpha.9"], "0.2.0-alpha.10"],
      expected: true,
      it: "should detect 10 > 9 in alpha versions",
    },
    {
      input: [["0.1.0", "0.2.0"], "0.2.1"],
      expected: true,
      it:
        "should detect a minor revision bump as greater than the previous version",
    },
  ].map(fixture =>
    Object.assign(fixture, {
      actual: compareSemvers.apply(null, fixture.input),
    })
  );

  fixtures.forEach(fixture =>
    it(fixture.it, () => expect(fixture.actual).to.deep.equal(fixture.expected))
  );
});
