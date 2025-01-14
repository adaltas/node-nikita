import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.cluster.delete", function () {
  if (!test.tags.incus) return;

  they("delete a cluster", function ({ ssh }) {
    this.timeout(-1); // yum install take a lot of time
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        const cluster = {
          networks: {
            nktincuspub: {
              "ipv4.address": "10.10.40.1/24",
              "ipv4.nat": true,
              "ipv6.address": "none",
            },
          },
          containers: {
            "nikita-cluster-del-1": {
              image: `images:${test.images.alpine}`,
              nic: {
                eth0: {
                  name: "eth0",
                  nictype: "bridged",
                  parent: "nktincuspub",
                },
              },
            },
            "nikita-cluster-del-2": {
              image: `images:${test.images.alpine}`,
              nic: {
                eth0: {
                  name: "eth0",
                  nictype: "bridged",
                  parent: "nktincuspub",
                },
              },
            },
          },
        };
        await registry.register("clean", async function () {
          // Status modified if cluster deleted
          await this.incus.cluster.delete({ ...cluster, force: true });
        });
        await registry.register("test", async function () {
          await this.incus.cluster(cluster);
          const { $status } = await this.incus.cluster.delete({
            ...cluster,
            force: true,
          });
          $status.should.be.true();
          // Containers and network shall no longer exist
          const instances = await this.incus
            .list({
              type: "container",
            })
            .then(({ instances }) =>
              instances.map((instance) => instance.name),
            );
          instances.should.not.containEql("nikita-cluster-del-1");
          instances.should.not.containEql("nikita-cluster-del-2");
          const networks = await this.incus.network
            .list()
            .then(({ networks }) => networks.map((network) => network.name));
          networks.should.not.containEql("nktincuspub");
        });
        try {
          // await this.clean();
          await this.test();
        } finally {
          await this.clean();
        }
      },
    );
  });

  describe("option `force`", function () {
    they(
      "when `false`, generate an error if cluster is running",
      function ({ ssh }) {
        this.timeout(-1); // yum install take a lot of time
        return nikita(
          {
            $ssh: ssh,
          },
          async function () {
            const cluster = {
              networks: {
                nktincuspub: {
                  "ipv4.address": "10.10.40.1/24",
                  "ipv4.nat": true,
                  "ipv6.address": "none",
                },
              },
              containers: {
                "nikita-cluster-del-1": {
                  image: `images:${test.images.alpine}`,
                  nic: {
                    eth0: {
                      name: "eth0",
                      nictype: "bridged",
                      parent: "nktincuspub",
                    },
                  },
                },
                "nikita-cluster-del-2": {
                  image: `images:${test.images.alpine}`,
                  nic: {
                    eth0: {
                      name: "eth0",
                      nictype: "bridged",
                      parent: "nktincuspub",
                    },
                  },
                },
              },
            };
            await this.incus.cluster(cluster);
            await this.wait({ time: 200 });
            await this.incus.cluster
              .delete(cluster)
              .should.be.rejectedWith(/^NIKITA_EXECUTE_EXIT_CODE_INVALID:/);
            await this.incus.cluster.delete({ ...cluster, force: true });
          },
        );
      },
    );

    they("when `true`, force deletion", function ({ ssh }) {
      this.timeout(-1); // yum install take a lot of time
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          const cluster = {
            networks: {
              nktincuspub: {
                "ipv4.address": "10.10.40.1/24",
                "ipv4.nat": true,
                "ipv6.address": "none",
              },
            },
            containers: {
              "nikita-cluster-del-1": {
                image: `images:${test.images.alpine}`,
                nic: {
                  eth0: {
                    name: "eth0",
                    nictype: "bridged",
                    parent: "nktincuspub",
                  },
                },
              },
              "nikita-cluster-del-2": {
                image: `images:${test.images.alpine}`,
                nic: {
                  eth0: {
                    name: "eth0",
                    nictype: "bridged",
                    parent: "nktincuspub",
                  },
                },
              },
            },
          };
          await registry.register("clean", async function () {
            await this.incus.cluster.delete({
              containers: cluster.containers,
              networks: cluster.networks,
              force: true,
            });
          });
          await registry.register("test", async function () {
            await this.incus.cluster(cluster);
            const { $status } = await this.incus.cluster.delete({
              ...cluster,
              force: true,
            });
            $status.should.be.true();
            const { instances } = await this.incus.list({
              type: "container",
            });
            instances.should.not.containEql("nikita-cluster-del-1");
            instances.should.not.containEql("nikita-cluster-del-2");
            const { networks } = await this.incus.network.list();
            networks.should.not.containEql("nktincuspub");
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
});
