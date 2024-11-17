import nikita from "@nikitajs/core";
import test from "../../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage.volume.attach", function () {
  if (!test.tags.incus) return;

  describe("attach", function () {
    they("should attach a volume", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete({
              container: "nikita-container-attach-1",
            });
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-attach-1",
              name: "nikita-volume-attach-1",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-attach-1",
            });
          });
          registry.register("test", async function () {
            // Create storage and volume
            await this.incus.storage({
              name: "nikita-storage-attach-1",
              driver: "zfs",
            });
            await this.incus.storage.volume({
              name: "nikita-volume-attach-1",
              pool: "nikita-storage-attach-1",
            });
            // Create instance
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-container-attach-1",
            });
            // Attach volume to instance
            const { $status } = await this.incus.storage.volume.attach({
              pool: "nikita-storage-attach-1",
              name: "nikita-volume-attach-1",
              container: "nikita-container-attach-1",
              device: "osd",
              path: "/osd/",
            });
            $status.should.be.eql(true);
            // Check if volume is attached
            const { $status: queryStatus, data } = await this.incus.query({
              path: "/1.0/instances/nikita-container-attach-1",
            });
            queryStatus.should.be.eql(true);
            data.devices.should.containEql({
              osd: {
                type: "disk",
                source: "nikita-volume-attach-1",
                pool: "nikita-storage-attach-1",
                path: "/osd/",
              },
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

    if (!test.tags.incus_vm) return;

    they("should attach a block volume on a vm", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete({
              container: "nikita-container-attach-2",
            });
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-attach-2",
              name: "nikita-volume-attach-2",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-attach-2",
            });
          });
          registry.register("test", async function () {
            // Create storage and volume
            await this.incus.storage({
              name: "nikita-storage-attach-2",
              driver: "zfs",
            });
            await this.incus.storage.volume({
              name: "nikita-volume-attach-2",
              pool: "nikita-storage-attach-2",
              content: "block",
            });
            // Create instance
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-container-attach-2",
              vm: true,
            });
            // Attach volume to instance
            const { $status } = await this.incus.storage.volume.attach({
              pool: "nikita-storage-attach-2",
              name: "nikita-volume-attach-2",
              container: "nikita-container-attach-2",
              device: "osd",
            });
            $status.should.be.eql(true);
            // Check if volume is attached
            const { $status: queryStatus, data } = await this.incus.query({
              path: "/1.0/instances/nikita-container-attach-2",
            });
            queryStatus.should.be.eql(true);
            data.devices.should.containEql({
              osd: {
                type: "disk",
                source: "nikita-volume-attach-2",
                pool: "nikita-storage-attach-2",
              },
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
  });

  describe("rejection", function () {
    they("did not specify the path with filesystem", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete({
              container: "nikita-container-attach-1",
            });
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-attach-1",
              name: "nikita-volume-attach-1",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-attach-1",
            });
          });
          registry.register("test", async function () {
            // Create storage and volume
            await this.incus.storage({
              name: "nikita-storage-attach-1",
              driver: "zfs",
            });
            await this.incus.storage.volume({
              name: "nikita-volume-attach-1",
              pool: "nikita-storage-attach-1",
            });
            // Create instance
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-container-attach-1",
            });
            // Attach volume to instance
            await this.incus.storage.volume
              .attach({
                pool: "nikita-storage-attach-1",
                name: "nikita-volume-attach-1",
                container: "nikita-container-attach-1",
                device: "osd",
              })
              .should.be.rejectedWith(
                /^Missing requirement: Path is required for filesystem type volumes./,
              );
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

    if (!test.tags.incus_vm) return;

    they("should attach a filesystem to a vm", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete({
              container: "nikita-container-attach-2",
            });
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-attach-2",
              name: "nikita-volume-attach-2",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-attach-2",
            });
          });
          registry.register("test", async function () {
            // Create storage and volume
            await this.incus.storage({
              name: "nikita-storage-attach-2",
              driver: "zfs",
            });
            await this.incus.storage.volume({
              name: "nikita-volume-attach-2",
              pool: "nikita-storage-attach-2",
            });
            // Create instance
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-container-attach-2",
              vm: true,
            });
            // Attach volume to instance
            await this.incus.storage.volume
              .attach({
                pool: "nikita-storage-attach-2",
                name: "nikita-volume-attach-2",
                container: "nikita-container-attach-2",
                device: "osd",
                path: "/osd/",
              })
              .should.be.rejectedWith(
                /^Type: virtual-machine can only mount block type volumes./,
              );
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

    they(
      "should attach a block volume to a container",
      async function ({ ssh }) {
        await nikita(
          {
            $ssh: ssh,
          },
          async function ({ registry }) {
            registry.register("clean", async function () {
              await this.incus.delete({
                container: "nikita-container-attach-3",
              });
              await this.incus.storage.volume.delete({
                pool: "nikita-storage-attach-3",
                name: "nikita-volume-attach-3",
              });
              await this.incus.storage.delete({
                name: "nikita-storage-attach-3",
              });
            });
            registry.register("test", async function () {
              // Create storage and volume
              await this.incus.storage({
                name: "nikita-storage-attach-3",
                driver: "zfs",
              });
              await this.incus.storage.volume({
                name: "nikita-volume-attach-3",
                pool: "nikita-storage-attach-3",
                content: "block",
              });
              // Create instance
              await this.incus.init({
                image: `images:${test.images.alpine}`,
                container: "nikita-container-attach-3",
              });
              // Attach volume to instance
              await this.incus.storage.volume
                .attach({
                  pool: "nikita-storage-attach-3",
                  name: "nikita-volume-attach-3",
                  container: "nikita-container-attach-3",
                  device: "osd",
                  path: "/osd/",
                })
                .should.be.rejectedWith(
                  /^Type: container can only mount filesystem type volumes./,
                );
            });
            try {
              await this.clean();
              await this.test();
            } finally {
              await this.clean();
            }
          },
        );
      },
    );

    they("should forget the volume", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete({
              container: "nikita-container-attach-4",
            });
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-attach-4",
              name: "nikita-volume-attach-4",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-attach-4",
            });
          });
          registry.register("test", async function () {
            // Create storage and volume
            await this.incus.storage({
              name: "nikita-storage-attach-4",
              driver: "zfs",
            });
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-container-attach-4",
            });
            // Attach volume to instance
            await this.incus.storage.volume
              .attach({
                pool: "nikita-storage-attach-4",
                name: "nikita-volume-attach-4",
                container: "nikita-container-attach-4",
                device: "osd",
                path: "/osd/",
              })
              .should.be.rejectedWith(
                'NIKITA_INCUS_VOLUME_ATTACH: volume "nikita-volume-attach-4" does not exist.',
              );
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

    they("should forget the container", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete({
              container: "nikita-container-attach-5",
            });
            await this.incus.storage.volume.delete({
              pool: "nikita-storage-attach-5",
              name: "nikita-volume-attach-5",
            });
            await this.incus.storage.delete({
              name: "nikita-storage-attach-5",
            });
          });
          registry.register("test", async function () {
            // Create storage and volume
            await this.incus.storage({
              name: "nikita-storage-attach-5",
              driver: "zfs",
            });
            await this.incus.storage.volume({
              name: "nikita-volume-attach-5",
              pool: "nikita-storage-attach-5",
            });
            // Attach volume to instance
            await this.incus.storage.volume
              .attach({
                pool: "nikita-storage-attach-5",
                name: "nikita-volume-attach-5",
                container: "nikita-container-attach-5",
                device: "osd",
                path: "/osd/",
              })
              .should.be.rejectedWith(
                'NIKITA_INCUS_VOLUME_ATTACH: container "nikita-container-attach-5" does not exist.',
              );
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
