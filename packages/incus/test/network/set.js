import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.network.set", function () {
  if (!test.tags.incus) return;

  they("modify properties", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function ({ registry }) {
      registry.register("clean", async function () {
        await this.incus.network.delete("nkt-set-modify");
      });
      registry.register("test", async function () {
        await this.incus.network("nkt-set-modify", {
          properties: { "ipv4.nat": true },
        });
        // Status is true after modification
        await this.incus.network
          .set("nkt-set-modify", {
            properties: { "ipv4.nat": false },
          })
          .then(({ $status }) => $status)
          .should.finally.be.true();
        // Status is false when no modification
        await this.incus.network
          .set("nkt-set-modify", {
            properties: { "ipv4.nat": false },
          })
          .then(({ $status }) => $status)
          .should.finally.be.false();
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
