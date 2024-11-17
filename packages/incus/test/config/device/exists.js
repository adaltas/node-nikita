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
      async function () {
        await this.incus.delete({
          container: "nikita-config-device-exists-1",
          force: true,
        });
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          container: "nikita-config-device-exists-1",
        });
        const { exists } = await this.incus.config.device.exists({
          container: "nikita-config-device-exists-1",
          device: "test",
        });
        exists.should.be.false();
      },
    );
  });

  they("Device exists", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.delete({
          container: "nikita-config-device-exists-2",
          force: true,
        });
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          container: "nikita-config-device-exists-2",
        });
        await this.incus.config.device({
          container: "nikita-config-device-exists-2",
          device: "test",
          type: "unix-char",
          properties: {
            source: "/dev/urandom",
            path: "/testrandom",
          },
        });
        const { exists } = await this.incus.config.device.exists({
          container: "nikita-config-device-exists-2",
          device: "test",
        });
        exists.should.be.true();
      },
    );
  });
});
