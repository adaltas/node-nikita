import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.project.exists", function () {
  if (!test.tags.incus) return;

  they("project does not exist", async function ({ ssh }) {
    const { exists } = await nikita({ ssh: ssh }).incus.project.exists(
      "invalid",
    );
    exists.should.be.false();
  });

  they("project exists", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function ({ registry }) {
      registry.register("clean", async function () {
        await this.incus.project.delete("nikita-project-exists");
      });
      registry.register("test", async function () {
        await this.incus.project("nikita-project-exists");
        const { exists } = await this.incus.project.exists(
          "nikita-project-exists",
        );
        exists.should.be.true();
      });
      try {
        await this.clean();
        await this.test();
      } finally {
        await this.clean();
      }
    });
  });
});
