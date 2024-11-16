import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage.exists", function () {
  if (!test.tags.incus) {
    return;
  }

  it("argument is a string", async function () {
    await nikita.incus.storage.exists(
      "nikita-storage-exists-1",
      function ({ config }) {
        config.name.should.eql("nikita-storage-exists-1");
      },
    );
  });

  they("with existing storage", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.storage({
          name: "nikita-storage-exists-2",
          driver: "zfs",
        });
        const { exists } = await this.incus.storage.exists(
          "nikita-storage-exists-2",
        );
        exists.should.be.true();
        await this.incus.storage.delete("nikita-storage-exists-2");
      },
    );
  });

  they("with missing storage", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        const { exists } = await this.incus.storage.exists(
          "nikita-storage-exists-3",
        );
        exists.should.be.false();
      },
    );
  });
});
