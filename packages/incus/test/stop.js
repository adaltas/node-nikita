import nikita from "@nikitajs/core";
import test from "./test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.stop", function () {
  if (!test.tags.incus) return;

  it("argument is a string", function () {
    return nikita.incus.stop("nikita-stop-1", function ({ config }) {
      config.name.should.eql("nikita-stop-1");
    });
  });

  they("Already stopped", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      function ({ registry }) {
        registry.register("clean", function () {
          return this.incus.delete("nikita-stop-2", { force: true });
        });

        return async function () {
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-stop-2",
          });
          const { $status } = await this.incus.stop({
            name: "nikita-stop-2",
          });
          $status.should.be.false();
          await this.clean();
        }.call(this);
      },
    );
  });

  they("Stop a container", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      function ({ registry }) {
        registry.register("clean", function () {
          return this.incus.delete("nikita-stop-3", { force: true });
        });
        return async function () {
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-stop-3",
            start: true,
          });
          const { $status } = await this.incus.stop({
            name: "nikita-stop-3",
          });
          $status.should.be.true();
          await this.clean();
        }.call(this);
      },
    );
  });
});
