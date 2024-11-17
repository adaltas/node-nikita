import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.project.delete", function () {
  if (!test.tags.incus) return;

  they("delete a missing project", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function () {
      const { $status } = await this.incus.project.delete(
        "nikita-project-delete",
      );
      $status.should.be.false();
    });
  });

  they("delete an existing project", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function ({ registry }) {
      registry.register("clean", async function () {
        await this.incus.project.delete("nikita-project-delete");
      });
      registry.register("test", async function () {
        await this.incus.project("nikita-project-delete");
        const { $status } = await this.incus.project.delete(
          "nikita-project-delete",
        );
        $status.should.be.true();
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
