import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.network.detach", function () {
  if (!test.tags.incus) return;

  they("Detach a network from a container", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.delete({
            container: "nkt-detach-1-container",
            force: true,
          });
          await this.incus.network.delete({
            name: "nkt-detach-1",
          });
        });
        await registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nkt-detach-1-container",
          });
          await this.incus.network({
            name: "nkt-detach-1",
          });
          await this.incus.network.attach({
            name: "nkt-detach-1",
            container: "nkt-detach-1-container",
          });
          const { $status } = await this.incus.network.detach({
            name: "nkt-detach-1",
            container: "nkt-detach-1-container",
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

  they("Network already detached", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.delete({
            container: "nkt-detach-2-container",
            force: true,
          });
          await this.incus.network.delete({
            name: "nkt-detach-2",
          });
        });
        await registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nkt-detach-2-container",
          });
          await this.incus.network({
            name: "nkt-detach-2",
          });
          const { $status } = await this.incus.network.detach({
            name: "nkt-detach-2",
            container: "nkt-detach-2-container",
          });
          $status.should.be.false();
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
