import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";
const they = mochaThey(test.config);

describe("incus.network.delete", function () {
  if (!test.tags.incus) return;

  they("Delete a network", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.network("nkt-delete-1");
        const { $status } = await this.incus.network.delete("nkt-delete-1");
        $status.should.be.true();
        await this.incus.network
          .list()
          .then(({ networks }) => networks.map((network) => network.name))
          .should.finally.not.containEql("nkt-delete-1");
      },
    );
  });

  they("Network already deleted", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.network("nkt-delete-2");
        await this.incus.network.delete("nkt-delete-2");
        const { $status } = await this.incus.network.delete("nkt-delete-2");
        $status.should.be.false();
      },
    );
  });
});
