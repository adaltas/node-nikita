import nikita from "@nikitajs/core";
import test from "./test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.init", function () {
  if (!test.tags.incus) return;

  describe("schema", function () {
    it("Container name is between 1 and 63 characters long", function () {
      return nikita.incus
        .init({
          image: `images:${test.images.alpine}`,
          name: "very-long-long-long-long-long-long-long-long-long-long-long-long-long-name",
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
          message: [
            "NIKITA_SCHEMA_VALIDATION_CONFIG:",
            "one error was found in the configuration of action `incus.init`:",
            "#/definitions/config/properties/name/pattern config/name must match pattern",
            '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",',
            'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".',
          ].join(" "),
        });
    });

    it("Container name accepts letters, numbers and dashes from the ASCII table", function () {
      return nikita.incus
        .init({
          image: `images:${test.images.alpine}`,
          name: "my_name",
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
          message: [
            "NIKITA_SCHEMA_VALIDATION_CONFIG:",
            "one error was found in the configuration of action `incus.init`:",
            "#/definitions/config/properties/name/pattern config/name must match pattern",
            '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",',
            'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".',
          ].join(" "),
        });
    });

    it("Container name must not start with a digit", function () {
      return nikita.incus
        .init({
          image: `images:${test.images.alpine}`,
          name: "1u",
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
          message: [
            "NIKITA_SCHEMA_VALIDATION_CONFIG:",
            "one error was found in the configuration of action `incus.init`:",
            "#/definitions/config/properties/name/pattern config/name must match pattern",
            '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",',
            'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".',
          ].join(" "),
        });
    });

    it("Container name must not start with a dash", function () {
      return nikita.incus
        .init({
          image: `images:${test.images.alpine}`,
          name: "-u1",
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
          message: [
            "NIKITA_SCHEMA_VALIDATION_CONFIG:",
            "one error was found in the configuration of action `incus.init`:",
            "#/definitions/config/properties/name/pattern config/name must match pattern",
            '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",',
            'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".',
          ].join(" "),
        });
    });

    it("Container name is not end with a dash", function () {
      return nikita.incus
        .init({
          image: `images:${test.images.alpine}`,
          name: "u1-",
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
          message: [
            "NIKITA_SCHEMA_VALIDATION_CONFIG:",
            "one error was found in the configuration of action `incus.init`:",
            "#/definitions/config/properties/name/pattern config/name must match pattern",
            '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",',
            'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".',
          ].join(" "),
        });
    });
  });

  describe("container", function () {
    they("Init a new container", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-init-1", { force: true });
          });
          await this.clean();
          const { $status } = await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-init-1",
          });
          $status.should.be.true();
          await this.clean();
        },
      );
    });

    they("Config `start`", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-init-2", { force: true });
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-init-2",
            start: true,
          });
          const { $status } = await this.incus.state.running({
            name: "nikita-init-2",
          });
          $status.should.be.true();
          await this.clean();
        },
      );
    });

    they("Validate name", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-init-3", { force: true });
          });
          await this.clean();
          const { $status } = await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-init-3",
          });
          $status.should.be.true();
          await this.clean();
        },
      );
    });

    they("Container already exist", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-init-4", { force: true });
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-init-4",
          });
          const { $status } = await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-init-4",
          });
          $status.should.be.false();
          await this.clean();
        },
      );
    });
  });

  describe("vm", function () {
    if (!test.tags.incus_vm) return;

    they("Init new VM", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-init-vm1", { force: true });
          });
          await this.clean();
          const { $status } = await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-init-vm1",
            vm: true,
          });
          $status.should.be.true();
          await this.clean();
        },
      );
    });

    they("VM already exist", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-init-vm2", { force: true });
          });
          registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              name: "nikita-init-vm2",
              vm: true,
            });
            const { $status } = await this.incus.init({
              image: `images:${test.images.alpine}`,
              name: "nikita-init-vm2",
              vm: true,
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
  });
});
