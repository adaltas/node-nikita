import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.network.exists", function () {
  if (!test.tags.incus) return;

  they("network does not exist", async function ({ ssh }) {
    const { exists } = await nikita({ ssh: ssh }).incus.network.exists(
      "invalid",
    );
    exists.should.be.false();
  });

  they("network exists", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function ({ registry }) {
      registry.register("clean", async function () {
        await this.incus.network.delete("nkt-exists");
      });
      registry.register("test", async function () {
        await this.incus.network("nkt-exists");
        const { exists } = await this.incus.network.exists("nkt-exists");
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
