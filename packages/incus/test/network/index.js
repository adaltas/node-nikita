import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";
const they = mochaThey(test.config);

describe("incus.network.create", function () {
  if (!test.tags.incus) return;

  they("schema dns.domain valid", function ({ ssh }) {
    return nikita({
      $ssh: ssh,
    }).incus.network({
      name: "nkt-network-1",
      properties: {
        "ipv4.address": "192.0.2.1/30",
        "dns.domain": "nikita.local",
      },
      $handler: () => {},
    });
  });

  they("schema dns.domain invalid", function ({ ssh }) {
    return nikita({
      $ssh: ssh,
    })
      .incus.network({
        name: "nkt-network-1",
        properties: {
          "ipv4.address": "192.0.2.1/30",
          "dns.domain": "(oo)",
        },
      })
      .should.be.rejectedWith({
        code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
      });
  });

  they("Create a new network", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.network.delete("nkt-network-2");
        });
        try {
          await this.clean();
          await this.incus.network("nkt-network-2").should.finally.match({
            $status: true,
          });
        } finally {
          await this.clean();
        }
      },
    );
  });

  they("Different types of config parameters", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.network.delete("nkt-network-3");
        });
        await registry.register("test", async function () {
          const { $status } = await this.incus.network({
            name: "nkt-network-3",
            properties: {
              "ipv4.address": "192.0.2.1/30",
              "ipv4.dhcp": false,
              "bridge.mtu": 2000,
            },
          });
          $status.should.be.true();
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

  they("Network already created", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.network.delete({
            name: "nkt-network-4",
          });
        });
        await registry.register("test", async function () {
          await this.incus.network({
            name: "nkt-network-4",
          });
          const { $status } = await this.incus.network({
            name: "nkt-network-4",
          });
          $status.should.be.false();
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

  they("Add new properties", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.network.delete({
            name: "nkt-network-5",
          });
        });
        await registry.register("test", async function () {
          await this.incus.network({
            name: "nkt-network-5",
          });
          const { $status } = await this.incus.network({
            name: "nkt-network-5",
            properties: {
              "ipv4.address": "192.0.2.1/30",
              "ipv4.dhcp": false,
            },
          });
          $status.should.be.true();
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

  they("Change a property", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.network.delete({
            name: "nkt-network-6",
          });
        });
        await registry.register("test", async function () {
          await this.incus
            .network({
              name: "nkt-network-6",
              properties: {
                "ipv4.address": "192.0.2.1/30",
                "ipv4.dhcp": true,
              },
            })
            .should.finally.match({
              $status: true,
            });
          await this.incus
            .network({
              name: "nkt-network-6",
              properties: {
                "ipv4.address": "192.0.2.1/30",
                "ipv4.dhcp": true,
              },
            })
            .should.finally.match({
              $status: false,
            });
          await this.incus
            .network({
              name: "nkt-network-6",
              properties: {
                "ipv4.address": "192.0.2.1/30",
                "ipv4.dhcp": false,
              },
            })
            .should.finally.match({
              $status: true,
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

  they("Configuration unchanged", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        await registry.register("clean", async function () {
          await this.incus.network.delete({
            name: "nkt-network-7",
          });
        });
        await registry.register("test", async function () {
          await this.incus.network({
            name: "nkt-network-7",
            properties: {
              "ipv4.address": "192.0.2.1/30",
            },
          });
          await this.incus
            .network({
              name: "nkt-network-7",
              properties: {
                "ipv4.address": "192.0.2.1/30",
              },
            })
            .should.finally.match({
              $status: false,
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
