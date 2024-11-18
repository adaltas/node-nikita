import nikita from "@nikitajs/core";
import test from "./test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.info", function () {
  if (!test.tags.incus) return;

  they("argument is a string", function () {
    return nikita.incus.info("nikita-info-1", function ({ config }) {
      return config.name.should.eql("nikita-info-1");
    });
  });

  they("existing container", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", function () {
          return this.incus.delete("nikita-info-2", { force: true });
        });
        await this.clean();
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          name: "nikita-info-2",
        });
        await this.incus
          .info("nikita-info-2")
          .should.finally.match({ container: { name: "nikita-info-2" } });
        await this.clean();
      },
    );
  });
});
