import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.state", function () {
  if (!test.tags.incus) return;

  it("argument is a string", async function () {
    await nikita.incus.state("nikita-state-1", function ({ config }) {
      config.name.should.eql("nikita-state-1");
    });
  });

  they("Show instance state", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", function () {
          return this.incus.delete("nikita-state-2", { force: true });
        });
        await this.clean();
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          name: "nikita-state-2",
        });
        const { $status, state } = await this.incus.state({
          name: "nikita-state-2",
        });
        $status.should.be.true();
        state.status.should.eql("Stopped");
        await this.clean();
      },
    );
  });

  they("Instance not found", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", function () {
          return this.incus.delete("nikita-state-3", { force: true });
        });
        await this.clean();
        await this.incus
          .state({
            name: "nikita-state-3",
          })
          .should.be.rejectedWith({
            exit_code: 1,
          });
        await this.clean();
      },
    );
  });
});
