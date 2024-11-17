import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.config.set", function () {
  if (!test.tags.incus) return;

  they("Set multiple keys", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.delete({
          container: "nikita-config-set-1",
          force: true,
        });
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          container: "nikita-config-set-1",
        });
        const { $status } = await this.incus.config.set({
          container: "nikita-config-set-1",
          properties: {
            "environment.MY_KEY_1": "my value 1",
            "environment.MY_KEY_2": "my value 2",
          },
        });
        $status.should.be.true();
        await this.incus.start({
          container: "nikita-config-set-1",
        });
        const { stdout: stdout1 } = await this.execute({
          command: "incus exec nikita-config-set-1 -- env | grep MY_KEY_1",
          trim: true,
        });
        stdout1.should.eql("MY_KEY_1=my value 1");
        const { stdout: stdout2 } = await this.execute({
          command: "incus exec nikita-config-set-1 -- env | grep MY_KEY_2",
          trim: true,
        });
        stdout2.should.eql("MY_KEY_2=my value 2");
      },
    );
  });

  they("Does not set the same configuration", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function () {
        await this.incus.delete({
          container: "nikita-config-set-2",
          force: true,
        });
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          container: "nikita-config-set-2",
        });
        const { $status: status1 } = await this.incus.config.set({
          container: "nikita-config-set-2",
          properties: {
            "environment.MY_KEY_1": "my value 1",
          },
        });
        status1.should.be.true();
        const { $status: status2 } = await this.incus.config.set({
          container: "nikita-config-set-2",
          properties: {
            "environment.MY_KEY_1": "my value 1",
          },
        });
        status2.should.be.false();
      },
    );
  });
});
