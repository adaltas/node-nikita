import nikita from "@nikitajs/core";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.network.attach", function () {
  if (!test.tags.incus) return;

  they("Attach a network to a container", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.delete({
            container: "u0",
            force: true,
          });
          await this.incus.network.delete({
            name: "nkt-attach-1",
          });
        });
        await registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "u0",
          });
          await this.incus.network({
            name: "nkt-attach-1",
          });
          const { $status } = await this.incus.network.attach({
            name: "nkt-attach-1",
            container: "u0",
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

  they("Network already attached", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.delete({
            container: "u0",
            force: true,
          });
          await this.incus.network.delete({
            name: "nkt-attach-2",
          });
        });
        await registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "u0",
          });
          await this.incus.network({
            name: "nkt-attach-2",
          });
          await this.incus.network.attach({
            name: "nkt-attach-2",
            container: "u0",
          });
          const { $status } = await this.incus.network.attach({
            name: "nkt-attach-2",
            container: "u0",
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
