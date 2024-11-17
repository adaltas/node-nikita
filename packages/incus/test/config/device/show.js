import nikita from "@nikitajs/core";
import test from "../../test.js";
import mochaThey from "mocha-they";
const they = mochaThey(test.config);

describe("incus.config.device.show", function () {
  if (!test.tags.incus) return;

  they("config output", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.delete({
          container: "nikita-config-show-1",
          force: true,
        });
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          container: "nikita-config-show-1",
        });
        await this.incus.config.device({
          container: "nikita-config-show-1",
          device: "test",
          type: "unix-char",
          properties: {
            source: "/dev/urandom",
            path: "/testrandom",
          },
        });
        const { $status, properties } = await this.incus.config.device.show({
          container: "nikita-config-show-1",
          device: "test",
        });
        $status.should.be.true();
        properties.should.eql({
          path: "/testrandom",
          source: "/dev/urandom",
          type: "unix-char",
        });
      },
    );
  });
});
