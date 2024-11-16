import nikita from "@nikitajs/core";
import test from "../../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage.volume.delete", function () {
  if (!test.tags.incus) return;

  they("delete a volume", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.storage({
          name: "nikita-storage-delete-1",
          driver: "zfs",
        });
        await this.incus.storage.volume({
          name: "nikita-volume-delete-1",
          pool: "nikita-storage-delete-1",
        });
        const { $status } = await this.incus.storage.volume.delete({
          pool: "nikita-storage-delete-1",
          name: "nikita-volume-delete-1",
        });
        await this.incus.storage.delete({
          name: "nikita-storage-delete-1",
        });
        $status.should.be.eql(true);
      },
    );
  });

  they("double delete a volume", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.storage({
          name: "nikita-storage-delete-2",
          driver: "zfs",
        });
        await this.incus.storage.volume({
          name: "nikita-volume-delete-2",
          pool: "nikita-storage-delete-2",
        });
        await this.incus.storage.volume.delete({
          pool: "nikita-storage-delete-2",
          name: "nikita-volume-delete-2",
        });
        const { $status } = await this.incus.storage.volume.delete({
          pool: "nikita-storage-delete-2",
          name: "nikita-volume-delete-2",
        });
        await this.incus.storage.delete({
          name: "nikita-storage-delete-2",
        });
        $status.should.be.eql(false);
      },
    );
  });
});
