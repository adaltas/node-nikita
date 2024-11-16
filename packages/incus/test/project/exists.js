import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.project.exists", function () {
  if (!test.tags.incus) return;

  they("project does not exists", async function ({ ssh }) {
    const { exists } = await nikita({ ssh: ssh }).incus.project.exists(
      "invalid",
    );
    exists.should.be.false();
  });
});
