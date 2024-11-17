import nikita from "@nikitajs/core";
import test from "./test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.start", function () {
  if (!test.tags.incus) return;

  it("argument is a string", async function () {
    await nikita.incus.start("nikita-start-1", function ({ config }) {
      config.container.should.eql("nikita-start-1");
    });
  });

  they("Start a container", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", function () {
          return this.incus.delete("nikita-start-2", { force: true });
        });
        await this.clean();
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          container: "nikita-start-2",
        });
        const { $status } = await this.incus.start({
          container: "nikita-start-2",
        });
        $status.should.be.true();
        await this.clean();
      },
    );
  });

  they("Already started", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", function () {
          return this.incus.delete("nikita-start-3", { force: true });
        });
        await this.clean();
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          container: "nikita-start-3",
        });
        await this.incus.start({
          container: "nikita-start-3",
        });
        const { $status } = await this.incus.start({
          container: "nikita-start-3",
        });
        $status.should.be.false();
        await this.clean();
      },
    );
  });
});
