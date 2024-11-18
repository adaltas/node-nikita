import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.goodie.prlimit", function () {
  if (!test.tags.incus_prlimit) {
    return;
  }

  they("stdout", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.delete({
            name: "nikita-goodies-prlimit-1",
            force: true,
          });
        });
        registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-goodies-prlimit-1",
            start: true,
          });
          await this.incus.goodies.prlimit({
            name: "nikita-goodies-prlimit-1",
          });
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
