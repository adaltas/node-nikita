import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.cluster.lifecycle", function () {
  if (!test.tags.incus) return;

  they("prevision and provision", function ({ ssh }) {
    this.timeout(-1);
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        const cluster = {
          containers: {
            "nikita-cluster-lifecycle-1": {
              image: `images:${test.images.alpine}`,
            },
          },
        };
        await registry.register("clean", function () {
          return this.incus.cluster.delete(cluster, { force: true });
        });
        await registry.register("test", async function () {
          const lifecycle = [];
          await this.incus.cluster(cluster, {
            prevision: function ({ config }) {
              lifecycle.push("prevision");
              config.containers.should.have.property(
                "nikita-cluster-lifecycle-1",
              );
            },
            prevision_container: function ({ config }) {
              lifecycle.push("prevision_container");
              config.name.should.eql("nikita-cluster-lifecycle-1");
            },
            provision: function ({ config }) {
              lifecycle.push("provision");
              config.containers.should.have.property(
                "nikita-cluster-lifecycle-1",
              );
            },
            provision_container: function ({ config }) {
              lifecycle.push("provision_container");
              config.name.should.eql("nikita-cluster-lifecycle-1");
            },
          });
          lifecycle.should.eql([
            "prevision",
            "prevision_container",
            "provision_container",
            "provision",
          ]);
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
