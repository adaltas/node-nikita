import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage.delete", function () {
  if (!test.tags.incus) return;

  they("Delete a storage", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.storage({
          name: "nikita-storage-delete-1",
          driver: "zfs",
        });
        const { $status } = await this.incus.storage.delete({
          name: "nikita-storage-delete-1",
        });
        $status.should.be.true();
      },
    );
  });

  they("Storage already deleted", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.storage({
          name: "nikita-storage-delete-2",
          driver: "zfs",
        });
        await this.incus.storage.delete({
          name: "nikita-storage-delete-2",
        });
        const { $status } = await this.incus.storage.delete({
          name: "nikita-storage-delete-2",
        });
        $status.should.be.false();
      },
    );
  });
});
