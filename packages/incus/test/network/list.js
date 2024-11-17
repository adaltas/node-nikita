import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";
const they = mochaThey(test.config);

describe("incus.network.list", function () {
  if (!test.tags.incus) return;

  they("list all networks", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.network.delete({
            name: "nkttestnetlist",
          });
        });
        registry.register("test", async function () {
          await this.incus.network({
            name: "nkttestnetlist",
            properties: {
              "ipv4.address": "192.0.2.1/30",
              "dns.domain": "nikita.net.test",
            },
          });
          await this.incus.network.list().then(({ $status, networks }) => {
            $status.should.be.true();
            networks
              .map((network) => network.name)
              .should.containEql("nkttestnetlist");
          });
        });
        try {
          await this.clean();
          await this.test();
        } finally {
          await this.clean();
        }
      },
    );
  });
});
