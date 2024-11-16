import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.project", function () {
  if (!test.tags.incus) return;

  they("create a new project", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function ({ registry }) {
      registry.register("clean", async function () {
        await this.incus.project.delete("nikita-project-new");
      });
      registry.register("test", async function () {
        const { $status } = await this.incus.project({
          name: "nikita-project-new",
        });
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

  they("project already created", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function ({ registry }) {
      registry.register("clean", async function () {
        await this.incus.project.delete("nikita-project-new");
      });
      registry.register("test", async function () {
        await this.incus.project("nikita-project-new");
        const { $status } = await this.incus.project("nikita-project-new");
        $status.should.be.false();
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
