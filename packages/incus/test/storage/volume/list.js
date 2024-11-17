import nikita from "@nikitajs/core";
import test from "../../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage.volume.list", function () {
  if (!test.tags.incus) return;

  they("list all volumes in a pool", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.storage.volume.delete({
            pool: "nikita-storage-list-1",
            name: "nikita-volume-list-1",
          });
          await this.incus.storage.delete({
            name: "nikita-storage-list-1",
          });
        });
        registry.register("test", async function () {
          await this.incus.storage({
            name: "nikita-storage-list-1",
            driver: "zfs",
          });
          await this.incus.storage.volume({
            name: "nikita-volume-list-1",
            pool: "nikita-storage-list-1",
          });
          await this.incus.storage.volume
            .list({
              pool: "nikita-storage-list-1",
            })
            .then(({ $status, volumes }) => {
              $status.should.be.eql(true);
              volumes
                .map((volume) => volume.name)
                .should.containEql("nikita-volume-list-1");
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

  they("list all volumes in an non-existing pool", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function () {
        const { $status } = await this.incus.storage.volume.list({
          pool: "nikita-storage-list-2",
        });
        $status.should.be.eql(false);
      },
    );
  });
});
