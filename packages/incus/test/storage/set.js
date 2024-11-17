import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage.set", function () {
  if (!test.tags.incus) return;

  they("update and set a new property", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function ({ registry }) {
      registry.register("clean", async function () {
        await this.incus.storage.delete("nikita-storage-set-1");
      });
      registry.register("test", async function () {
        await this.incus.storage({
          name: "nikita-storage-set-1",
          driver: "zfs",
          properties: {
            size: "5GiB",
          },
        });
        // Detect change of status
        const { $status } = await this.incus.storage.set({
          name: "nikita-storage-set-1",
          properties: {
            size: "10GiB",
            "zfs.clone_copy": "false",
          },
        });
        $status.should.be.true();
        // Ensure changes are applied
        const { storage } = await this.incus.storage.show(
          "nikita-storage-set-1",
        );
        storage.should.match({
          config: {
            size: "10GiB",
            "zfs.clone_copy": "false",
          },
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

  they("detect no change", async function ({ ssh }) {
    return nikita({ ssh: ssh }, async function ({ registry }) {
      registry.register("clean", async function () {
        await this.incus.storage.delete("nikita-storage-set-1");
      });
      registry.register("test", async function () {
        await this.incus.storage({
          name: "nikita-storage-set-1",
          driver: "zfs",
          properties: {
            size: "5GiB",
            "zfs.clone_copy": "false",
          },
        });
        const { $status } = await this.incus.storage.set({
          name: "nikita-storage-set-1",
          properties: {
            size: "5GiB",
            "zfs.clone_copy": "false",
          },
        });
        $status.should.be.false();
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
