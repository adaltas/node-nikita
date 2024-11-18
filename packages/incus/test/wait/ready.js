import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.wait.ready", function () {
  describe("For containers", function () {
    if (!test.tags.incus) return;

    they("wait for the container to be ready", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          await registry.register("clean", async function () {
            await this.incus.delete({
              name: "nikita-wait-1",
              force: true,
            });
          });

          await registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              name: "nikita-wait-1",
              start: true,
            });
            const { $status } = await this.incus.wait.ready("nikita-wait-1");
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
  });

  describe("For virtual machines", function () {
    if (!test.tags.incus_vm) return;

    they("wait for the virtual machine to be ready", async function ({ ssh }) {
      this.timeout(-1);
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          await registry.register("clean", async function () {
            await this.incus.delete({
              name: "nikita-wait-2",
              force: true,
            });
          });

          await registry.register("test", async function () {
            await this.incus.init({
              image: "images:ubuntu/24.04",
              name: "nikita-wait-2",
              vm: true,
              config: {
                "security.secureboot": false,
              },
              start: true,
            });
            const { $status } = await this.incus.wait.ready("nikita-wait-2");
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

    they("try to execute a command after booting", async function ({ ssh }) {
      this.timeout(-1);
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          await registry.register("clean", async function () {
            await this.incus.delete({
              name: "nikita-wait-3",
              force: true,
            });
          });

          await registry.register("test", async function () {
            await this.incus.init({
              image: "images:ubuntu/24.04",
              name: "nikita-wait-3",
              vm: true,
              config: {
                "security.secureboot": false,
              },
              start: true,
            });
            await this.incus.wait.ready("nikita-wait-3");
            const { $status } = await this.incus.exec({
              name: "nikita-wait-3",
              command: 'echo "hello"',
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

    they("try to execute a command before booting", async function ({ ssh }) {
      this.timeout(-1);
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          await registry.register("clean", async function () {
            await this.incus.delete({
              name: "nikita-wait-4",
              force: true,
            });
          });

          await registry.register("test", async function () {
            await this.incus.init({
              image: "images:ubuntu/24.04",
              name: "nikita-wait-4",
              vm: true,
              config: {
                "security.secureboot": false,
              },
              start: true,
            });
            await this.incus.exec({
              name: "nikita-wait-4",
              command: 'echo "hello"',
            });
          });

          try {
            await this.clean();
            await this.test();
          } catch (err) {
            err.$status.should.be.false();
          } finally {
            await this.clean();
          }
        },
      );
    });
  });
});
