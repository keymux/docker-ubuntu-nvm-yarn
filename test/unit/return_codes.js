const { expect } = require("chai");

const { _RETURN_CODES } = require("../../src/return_codes");

describe("return_codes.js", () => {
  const fixtures = ["FAIL", "FATAL", "SUCCESS"]
    .map(property => ({
      property,
    }))
    .map(fixture =>
      Object.assign({}, fixture, {
        value: _RETURN_CODES[fixture.property] % 256,
      })
    )
    .map(fixture =>
      Object.assign({}, fixture, {
        it: `should expose property ${
          fixture.property
        } as a unique modulus of 256 (${fixture.value})`,
      })
    )
    .forEach((fixture, i, fixtures) =>
      it(fixture.it, () => {
        expect(fixture.value).to.an("number");
        expect(fixture.value).to.be.at.least(0);
        expect(fixture.value).to.be.at.most(255);

        // Ensure no duplicate values
        fixtures.slice(0, i).forEach(previousFixture => {
          expect(fixture.value).to.not.equal(previousFixture.value);
        });
      })
    );
});
