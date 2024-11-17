import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.network.show", function () {
  if (!test.tags.incus) return;

  they("network does not exist", async function ({ ssh }) {
    await nikita({ ssh: ssh })
      .incus.network.show("invalid")
      .should.be.rejectedWith(
        [
          "NIKITA_INCUS_NETWORK_SHOW_NOT_EXIST:",
          "failed to retrieve network information,",
          "the network invalid does not exists or",
          "an unexpected error occured.",
        ].join(" "),
      );
  });

  they("network exists", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function ({ registry }) {
      registry.register("clean", async function () {
        await this.incus.network.delete("nkt-show");
      });
      registry.register("test", async function () {
        await this.incus.network("nkt-show");
        await this.incus.network
          .show("nkt-show")
          .then(({ network }) => network)
          .should.finally.match({
            config: { "ipv4.nat": "true" },
            description: "",
            name: "nkt-show",
            managed: true,
            type: "bridge",
          });
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
