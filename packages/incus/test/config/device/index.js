import nikita from "@nikitajs/core";
import test from "../../test.js";
import mochaThey from "mocha-they";
const they = mochaThey(test.config);

describe("incus.config.device", function () {
  if (!test.tags.incus) return;

  describe("schema", function () {
    it("Fail for invalid device type", function () {
      return nikita.incus.config
        .device({
          name: "nikita-config-device-1",
          device: "test",
          type: "invalid",
          properties: {
            prop: "/tmp",
          },
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
        });
    });

    it("Fail for absence of required config properties", function () {
      return nikita.incus.config
        .device({
          name: "nikita-config-device-2",
          device: "test",
          type: "disk",
          properties: {
            prop: "/tmp",
          },
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
        });
    });

    it("Fail for wrong type of config properties", function () {
      return nikita.incus.config
        .device({
          name: "nikita-config-device-3",
          device: "test",
          type: "disk",
          properties: {
            source: { key: "value" },
            path: { key: "value" },
          },
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
        });
    });
  });

  describe("action", function () {
    they("Create device without properties", async function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete({
              name: "nikita-config-device-4",
              force: true,
            });
          });
          registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              name: "nikita-config-device-4",
            });
            const { $status } = await this.incus.config.device({
              name: "nikita-config-device-4",
              device: "test",
              type: "unix-char",
              properties: {},
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

    they("Create device with properties", async function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete({
              name: "nikita-config-device-4",
              force: true,
            });
          });
          registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              name: "nikita-config-device-4",
            });
            const { $status } = await this.incus.config.device({
              name: "nikita-config-device-4",
              device: "test",
              type: "unix-char",
              properties: {
                source: "/dev/urandom",
                path: "/testrandom",
              },
            });
            $status.should.be.true();
            const result = await this.execute({
              command:
                "incus config device list nikita-config-device-4 | grep test",
            });
            result.$status.should.be.true();
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

    they("Device already created", async function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete({
              name: "nikita-config-device-5",
              force: true,
            });
          });
          registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              name: "nikita-config-device-5",
            });
            await this.incus.config.device({
              name: "nikita-config-device-5",
              device: "test",
              type: "unix-char",
              properties: {
                source: "/dev/urandom",
                path: "/testrandom",
              },
            });
            const { $status } = await this.incus.config.device({
              name: "nikita-config-device-5",
              device: "test",
              type: "unix-char",
              properties: {
                source: "/dev/urandom",
                path: "/testrandom",
              },
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

    they("Update device configuration", async function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete({
              name: "nikita-config-device-5",
              force: true,
            });
          });
          registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              name: "nikita-config-device-5",
            });
            await this.incus.config.device({
              name: "nikita-config-device-5",
              device: "test",
              type: "unix-char",
              properties: {
                source: "/dev/urandom1",
                path: "/testrandom1",
              },
            });
            const { $status } = await this.incus.config.device({
              name: "nikita-config-device-5",
              device: "test",
              type: "unix-char",
              properties: {
                source: "/dev/null",
              },
            });
            $status.should.be.true();
            const result = await this.execute({
              command:
                "incus config device show nikita-config-device-5 | grep 'source: /dev/null'",
            });
            result.$status.should.be.true();
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

    they(
      "Catch and format error when creating device",
      async function ({ ssh }) {
        return nikita(
          {
            $ssh: ssh,
          },
          async function ({ registry }) {
            registry.register("clean", async function () {
              await this.incus.delete({
                name: "nikita-config-device-7",
                force: true,
              });
            });
            registry.register("test", async function () {
              await this.incus.init({
                image: `images:${test.images.alpine}`,
                name: "nikita-config-device-7",
              });
              await this.incus.config
                .device({
                  name: "nikita-config-device-7",
                  device: "vpn",
                  type: "proxy",
                  properties: {
                    listen: "udp:127.0.0.1:1195",
                    connect: "udp:127.0.0.999:1194",
                  },
                })
                .should.be.rejectedWith({
                  message: [
                    "Error: Invalid devices:",
                    'Device validation failed for "vpn":',
                    'Invalid value for device option "connect":',
                    'Not an IP address "127.0.0.999"',
                  ].join(" "),
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
      },
    );

    they(
      "Catch and format error when updating device configuration",
      async function ({ ssh }) {
        return nikita(
          {
            $ssh: ssh,
          },
          async function ({ registry }) {
            registry.register("clean", async function () {
              await this.incus.delete({
                name: "nikita-config-device-8",
                force: true,
              });
            });
            registry.register("test", async function () {
              await this.incus.init({
                image: `images:${test.images.alpine}`,
                name: "nikita-config-device-8",
              });
              await this.incus.config.device({
                name: "nikita-config-device-8",
                device: "vpn",
                type: "proxy",
                properties: {
                  listen: "udp:127.0.0.1:1195",
                  connect: "udp:127.0.0.1:1194",
                },
              });
              await this.incus.config
                .device({
                  name: "nikita-config-device-8",
                  device: "vpn",
                  type: "proxy",
                  properties: {
                    listen: "udp:127.0.0.1:1195",
                    connect: "udp:127.0.0.999:1194",
                  },
                })
                .should.be.rejectedWith({
                  message: [
                    "Error: Invalid devices:",
                    'Device validation failed for "vpn":',
                    'Invalid value for device option "connect":',
                    'Not an IP address "127.0.0.999"',
                  ].join(" "),
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
      },
    );
  });
});
