import nikita from "@nikitajs/core";
import test from "../../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage.volume.get", function () {
  if (!test.tags.incus) return;

  they("get a volume", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.storage.volume.delete({
            pool: "nikita-storage-get-1",
            name: "nikita-volume-get-1",
          });
          await this.incus.storage.delete({
            name: "nikita-storage-get-1",
          });
        });
        registry.register("test", async function () {
          await this.incus.storage({
            name: "nikita-storage-get-1",
            driver: "zfs",
          });
          await this.incus.storage.volume({
            name: "nikita-volume-get-1",
            pool: "nikita-storage-get-1",
          });
          const { $status, data } = await this.incus.storage.volume.get({
            pool: "nikita-storage-get-1",
            name: "nikita-volume-get-1",
          });
          $status.should.be.eql(true);
          data.name.should.be.eql("nikita-volume-get-1");
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

  they("get a volume that doesn't exist", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.storage.volume.delete({
            pool: "nikita-storage-get-2",
            name: "nikita-volume-get-2",
          });
          await this.incus.storage.delete({
            name: "nikita-storage-get-2",
          });
        });
        registry.register("test", async function () {
          await this.incus.storage({
            name: "nikita-storage-get-2",
            driver: "zfs",
          });
          const { $status } = await this.incus.storage.volume.get({
            pool: "nikita-storage-get-2",
            name: "nikita-volume-get-2",
          });
          $status.should.be.eql(false);
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
