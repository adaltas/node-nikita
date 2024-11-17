import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.operation.list", function () {
  if (!test.tags.incus) return;

  they("call the action", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.operation.list();
      },
    );
  });
});
