import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage.show", function () {
  if (!test.tags.incus) return;

  they("delete a missing storage", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function () {
      await this.incus.storage
        .show("nikita-storage-show")
        .should.be.rejectedWith({
          code: "NIKITA_EXECUTE_EXIT_CODE_INVALID",
        });
    });
  });

  they("delete a storage", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function ({ registry }) {
      registry.register("clean", async function () {
        await this.incus.storage.delete("nikita-storage-show-1");
      });
      registry.register("test", async function () {
        await this.incus.storage({
          name: "nikita-storage-show-1",
          driver: "zfs",
        });
        const { data } = await this.incus.storage.show("nikita-storage-show-1");
        data.should.match({
          config: {
            size: /^\d+\w+$/,
            source: (s) => s.endsWith("nikita-storage-show-1.img"),
            "zfs.pool_name": "nikita-storage-show-1",
          },
          driver: "zfs",
          name: "nikita-storage-show-1",
          status: "Created",
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
