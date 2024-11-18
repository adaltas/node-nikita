import nikita from "@nikitajs/core";
import test from "./test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.exists", function () {
  if (!test.tags.incus) return;

  it("argument is a string", function () {
    return nikita.incus.exists("nikita-exists-1", function ({ config }) {
      config.name.should.eql("nikita-exists-1");
    });
  });

  they("existing container", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", function () {
          return this.incus.delete("nikita-exists-2", { force: true });
        });
        await this.clean();
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          name: "nikita-exists-2",
        });
        await this.incus
          .exists("nikita-exists-2")
          .should.finally.match({ exists: true });
        await this.clean();
      },
    );
  });

  they("missing container", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus
          .exists("nikita-exists-3")
          .should.finally.match({ exists: false });
      },
    );
  });
});
