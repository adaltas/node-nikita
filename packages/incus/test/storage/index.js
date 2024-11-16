import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage", function () {
  if (!test.tags.incus) return;

  they("Create a storage", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.storage.delete("nikita-storage-1");
        });
        registry.register("test", async function () {
          const { $status } = await this.incus.storage({
            name: "nikita-storage-1",
            driver: "zfs",
          });
          $status.should.be.true();
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

  they("Different types of config parameters", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.storage.delete("nikita-storage-2");
        });
        registry.register("test", async function () {
          const { $status } = await this.incus.storage({
            name: "nikita-storage-2",
            driver: "zfs",
            properties: {
              size: "10GB",
              "zfs.clone_copy": false,
            },
          });
          $status.should.be.true();
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

  they("Storage already created", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.storage.delete("nikita-storage-3");
        });
        registry.register("test", async function () {
          const { $status: $statusChanged } = await this.incus.storage({
            name: "nikita-storage-3",
            driver: "zfs",
          });
          $statusChanged.should.be.true();
          // No change shall be detected
          const { $status: $statusNotChanged } = await this.incus.storage({
            name: "nikita-storage-3",
            driver: "zfs",
          });
          $statusNotChanged.should.be.false();
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

  they("Update storage configuration", async function ({ ssh }) {
    // Note, storage is set to expand and not to shrink. With the later,
    // some configurations fail with the error "Pool cannot be shrunk".
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.storage.delete("nikita-storage-4");
        });
        registry.register("test", async function () {
          await this.incus.storage({
            name: "nikita-storage-4",
            driver: "zfs",
            properties: {
              size: "10GB",
            },
          });
          // Apply some changes, size is different, zfs.clone.copy is new
          const { $status: $statusChanged } = await this.incus.storage({
            name: "nikita-storage-4",
            driver: "zfs",
            properties: {
              size: "20GB",
              "zfs.clone_copy": false,
            },
          });
          $statusChanged.should.be.true();
          // Apply the same changes, no changes shall be detected
          const { $status: $statusNotChanged } = await this.incus.storage({
            name: "nikita-storage-4",
            driver: "zfs",
            properties: {
              size: "20GB",
              "zfs.clone_copy": false,
            },
          });
          $statusNotChanged.should.be.false();
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
