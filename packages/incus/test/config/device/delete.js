import nikita from "@nikitajs/core";
import test from "../../test.js";
import mochaThey from "mocha-they";
const they = mochaThey(test.config);

describe("incus.config.device.delete", function () {
  if (!test.tags.incus) return;

  they("Fail if the device does not exist", function ({ ssh }) {
    return async function () {
      await nikita(
        {
          $ssh: ssh,
        },
        async function () {
          await this.incus.delete({
            name: "nikita-config-device-delete-1",
            force: true,
          });
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-config-device-delete-1",
          });
          const { $status } = await this.incus.config.device.delete({
            device: "nondevice",
            name: "nikita-config-device-delete-1",
          });
          $status.should.be.false();
        },
      );
    };
  });

  they("Delete a device", function ({ ssh }) {
    return async function () {
      await nikita(
        {
          $ssh: ssh,
        },
        async function () {
          await this.incus.delete({
            name: "nikita-config-device-delete-2",
            force: true,
          });
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-config-device-delete-2",
          });
          await this.incus.config.device({
            name: "nikita-config-device-delete-2",
            device: "test",
            type: "unix-char",
            properties: {
              source: "/dev/urandom",
              path: "/testrandom",
            },
          });
          const { $status } = await this.incus.config.device.delete({
            device: "test",
            name: "nikita-config-device-delete-2",
          });
          $status.should.be.true();
        },
      );
    };
  });
});
