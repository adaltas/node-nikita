import path from "node:path";
import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);
const __dirname = new URL(".", import.meta.url).pathname;

describe("incus.cluster", function () {
  if (!test.tags.incus) return;

  describe("validation", function () {
    it("validate container.image", function () {
      nikita.incus
        .cluster(
          {
            containers: {
              nikita_cluster: {},
            },
          },
          () => {},
        )
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
        });
      nikita.incus
        .cluster(
          {
            containers: {
              nikita_cluster: {
                image: "images:centos/7",
              },
            },
          },
          () => {},
        )
        .should.be.fulfilled();
    });

    it("validate disk", function () {
      // Source is invalid
      nikita.incus
        .cluster(
          {
            containers: {
              nikita_cluster: {
                image: "images:centos/7",
                disk: {
                  nikitadir: true,
                  path: "/nikita",
                },
              },
            },
          },
          () => {},
        )
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
        });
      nikita.incus
        .cluster(
          {
            containers: {
              nikita_cluster: {
                image: "images:centos/7",
                disk: {
                  nikitadir: {
                    source:
                      process.env["NIKITA_HOME"] ||
                      path.join(__dirname, "../../../../"),
                    path: "/nikita",
                  },
                },
              },
            },
          },
          () => {},
        )
        .should.be.fulfilled();
    });
  });

  they("Create multiple devices", async function ({ ssh }) {
    this.timeout(-1); // yum/apk install take a lot of time
    await nikita(
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
            nktincusprv: {
              "ipv4.address": "10.10.50.1/24",
              "ipv4.nat": false,
              "ipv6.address": "none",
              "dns.domain": "nikita.local",
            },
          },
          containers: {
            "nikita-cluster-1": {
              image: `images:${test.images.alpine}`,
              disk: {
                nikitadir: {
                  source:
                    process.env["NIKITA_HOME"] ||
                    path.join(__dirname, "../../../../"),
                  path: "/nikita",
                },
              },
              nic: {
                eth0: {
                  name: "eth0",
                  nictype: "bridged",
                  parent: "nktincuspub",
                },
                eth1: {
                  name: "eth1",
                  nictype: "bridged",
                  parent: "nktincusprv",
                  "ipv4.address": "10.10.50.11",
                },
              },
            },
          },
        };
        await registry.register(["clean"], async function () {
          await this.incus.delete("nikita-cluster-1", {
            force: true,
          });
          await this.incus.network.delete("nktincuspub");
          await this.incus.network.delete("nktincusprv");
        });
        await registry.register(["test"], async function () {
          await this.incus.cluster(cluster);
          const { exists } = await this.incus.config.device.exists({
            name: "nikita-cluster-1",
            device: "nikitadir",
          });
          exists.should.be.true();
          const { exists: exists2 } = await this.incus.config.device.exists({
            name: "nikita-cluster-1",
            device: "eth0",
          });
          exists2.should.be.true();
          const { exists: exists3 } = await this.incus.config.device.exists({
            name: "nikita-cluster-1",
            device: "eth1",
          });
          exists3.should.be.true();
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

  they("ip and ssh", async function ({ ssh }) {
    this.timeout(-1);
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.delete({
            name: "nikita-cluster-2",
            force: true,
          });
          await this.incus.network.delete("nktincusprv");
        });
        await registry.register("test", async function ({ config }) {
          await this.incus.cluster({
            networks: {
              nktincusprv: {
                "ipv4.address": "192.0.2.5/30",
                "ipv4.nat": true,
                "ipv6.address": "none",
                "dns.domain": "nikita.local",
              },
            },
            containers: {
              "nikita-cluster-2": {
                image: `images:${test.images.alpine}`,
                nic: {
                  eth0: {
                    name: "eth0",
                    nictype: "bridged",
                    parent: "nktincusprv",
                    "ipv4.address": "192.0.2.6",
                  },
                },
                ssh: {
                  enabled: config.enabled,
                },
              },
            },
          });
          await this.incus.exec({
            name: "nikita-cluster-2",
            command: "nc -zvw2 192.0.2.6 22",
            code: config.enabled ? 0 : 1,
          });
        });

        try {
          await this.clean();
          await this.test({ enabled: true });
          await this.clean();
          await this.test({ enabled: false });
        } finally {
          await this.clean();
        }
      },
    );
  });

  if (!test.tags.incus_vm) return;

  they("init properties with vm", async function ({ ssh }) {
    this.timeout(-1);
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.delete({
            name: "nikita-cluster-3",
            force: true,
          });
        });
        await registry.register("test", async function () {
          await this.incus.cluster({
            containers: {
              "nikita-cluster-3": {
                image: "images:ubuntu/24.04",
                vm: true,
                properties: {
                  "security.secureboot": false,
                },
                ssh: { enabled: true },
              },
            },
          });
          const { running } = await this.incus.state.running({
            name: "nikita-cluster-3",
          });
          running.should.be.eql(true);
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
