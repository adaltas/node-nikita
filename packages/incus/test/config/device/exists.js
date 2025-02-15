import nikita from "@nikitajs/core";
import test from "../../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.config.device.exists", function () {
  if (!test.tags.incus) return;

  they("Device does not exist", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.delete({
            name: "nikita-config-device-exists-1",
            force: true,
          });
        });
        registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-config-device-exists-1",
          });
          const { exists } = await this.incus.config.device.exists({
            name: "nikita-config-device-exists-1",
            device: "test",
          });
          exists.should.be.false();
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

  they("Device exists", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.delete({
            name: "nikita-config-device-exists-2",
            force: true,
          });
        });
        registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-config-device-exists-2",
          });
          await this.incus.config.device({
            name: "nikita-config-device-exists-2",
            device: "test",
            type: "unix-char",
            properties: {
              source: "/dev/urandom",
              path: "/testrandom",
            },
          });
          const { exists } = await this.incus.config.device.exists({
            name: "nikita-config-device-exists-2",
            device: "test",
          });
          exists.should.be.true();
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
