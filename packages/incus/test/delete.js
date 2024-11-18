import nikita from "@nikitajs/core";
import test from "./test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.delete", function () {
  if (!test.tags.incus) return;
  they("Delete a container", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          name: "nikita-delete-1",
        });
        await this.incus.stop({
          name: "nikita-delete-1",
        });
        const { $status } = await this.incus.delete({
          name: "nikita-delete-1",
        });
        $status.should.be.true();
        const { $status: status2 } = await this.incus.delete({
          name: "nikita-delete-1",
        });
        status2.should.be.false();
      },
    );
  });

  they("Force deletion of a running container", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          name: "nikita-delete-2",
          start: true,
        });
        const { $status } = await this.incus.delete({
          name: "nikita-delete-2",
          force: true,
        });
        $status.should.be.true();
      },
    );
  });

  they("Not found", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.delete({
          // repeated to be sure the container is absent
          name: "nikita-delete-3",
        });
        const { $status } = await this.incus.delete({
          name: "nikita-delete-3",
        });
        $status.should.be.false();
      },
    );
  });
});
