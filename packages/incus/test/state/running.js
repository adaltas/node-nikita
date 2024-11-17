import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.test.running", function () {
  if (!test.tags.incus) return;

  it("argument is a string", function () {
    return nikita.incus.state.running(
      "nikita-running-1",
      function ({ config }) {
        return config.container.should.eql("nikita-running-1");
      },
    );
  });

  they("Running container", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          return this.incus.delete("nikita-running-2", { force: true });
        });
        registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-running-2",
            start: true,
          });
          const { $status } = await this.incus.state.running({
            container: "nikita-running-2",
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

  they("Stopped container", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.delete("nikita-running-3", { force: true });
        });
        registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-running-3",
          });
          const { running } = await this.incus.state.running({
            container: "nikita-running-3",
          });
          running.should.be.false();
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
