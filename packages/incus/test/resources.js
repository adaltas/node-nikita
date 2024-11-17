import nikita from "@nikitajs/core";
import test from "./test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.resources", function () {
  if (!test.tags.incus) return;

  they("check the cpu and the memory", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function () {
        const { $status, resources } = await this.incus.resources();
        $status.should.eql(true);
        ({
          cpus: resources.cpu.total.toString(),
          memory: resources.memory.total.toString(),
        }).should.match({
          cpus: /^\d+$/,
          memory: /^\d+$/,
        });
      },
    );
  });
});
