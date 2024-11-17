import nikita from "@nikitajs/core";
import test from "../../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage.volume", function () {
  if (!test.tags.incus) return;

  describe("volume creation", function () {
    they("create a volume", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-create-1",
              name: "nikita-volume-create-1",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-create-1",
            });
          });
          registry.register("test", async function () {
            await this.incus.storage({
              name: "nikita-storage-create-1",
              driver: "zfs",
            });
            const { $status } = await this.incus.storage.volume({
              name: "nikita-volume-create-1",
              pool: "nikita-storage-create-1",
            });
            $status.should.be.eql(true);
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

    they("create a volume in a non-existing pool", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-create-2",
              name: "nikita-volume-create-2",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-create-2",
            });
          });
          registry.register("test", async function () {
            const { $status } = await this.incus.storage.volume({
              name: "nikita-volume-create-2",
              pool: "nikita-storage-create-2",
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

    they("create two times the same volume", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-create-3",
              name: "nikita-volume-create-3",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-create-3",
            });
          });
          registry.register("test", async function () {
            await this.incus.storage({
              name: "nikita-storage-create-3",
              driver: "zfs",
            });
            let { $status } = await this.incus.storage.volume({
              name: "nikita-volume-create-3",
              pool: "nikita-storage-create-3",
            });
            $status.should.be.eql(true);
            ({ $status } = await this.incus.storage.volume({
              name: "nikita-volume-create-3",
              pool: "nikita-storage-create-3",
            }));
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

  describe("volume configuration", function () {
    they("create a volume with config", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-config-1",
              name: "nikita-volume-config-1",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-config-1",
            });
          });
          registry.register("test", async function () {
            await this.incus.storage({
              name: "nikita-storage-config-1",
              driver: "zfs",
            });
            await this.incus.storage.volume({
              name: "nikita-volume-config-1",
              pool: "nikita-storage-config-1",
              properties: {
                size: "10GB",
              },
            });
            const { volume } = await this.incus.storage.volume.get({
              pool: "nikita-storage-config-1",
              name: "nikita-volume-config-1",
            });
            volume.config.size.should.be.eql("10GB");
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

    they("create a volume with wrong config", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-config-2",
              name: "nikita-volume-config-2",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-config-2",
            });
          });
          registry.register("test", async function () {
            await this.incus.storage({
              name: "nikita-storage-config-2",
              driver: "zfs",
            });
            const { $status } = await this.incus.storage.volume({
              name: "nikita-volume-config-2",
              pool: "nikita-storage-config-2",
              properties: {
                size: "10gb",
              },
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

    they("create a volume filesystem", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-config-3",
              name: "nikita-volume-config-3",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-config-3",
            });
          });
          registry.register("test", async function () {
            await this.incus.storage({
              name: "nikita-storage-config-3",
              driver: "zfs",
            });
            await this.incus.storage.volume({
              name: "nikita-volume-config-3",
              pool: "nikita-storage-config-3",
              content: "block",
            });
            const { volume } = await this.incus.storage.volume.get({
              pool: "nikita-storage-config-3",
              name: "nikita-volume-config-3",
            });
            volume.content_type.should.be.eql("block");
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
});
