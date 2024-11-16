import nikita from "@nikitajs/core";
import test from "./test.coffee";
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
        const { $status, config } = await this.incus.resources();
        $status.should.eql(true);
        ({
          cpus: config.cpu.total.toString(),
          memory: config.memory.total.toString(),
        }).should.match({
          cpus: /^\d+$/,
          memory: /^\d+$/,
        });
      },
    );
  });
});
