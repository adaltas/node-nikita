import nikita from "@nikitajs/core";
import test from "../../test.coffee";

describe("plugins.tools.schema", function () {
  if (!test.tags.api) return;

  describe("usage", function () {
    it("expose the `ajv` instance", function () {
      return nikita(({ tools: { schema } }) => {
        schema.ajv.should.be.an.Object();
      });
    });

    it("`add` registers new schemas", function () {
      return nikita(({ tools: { schema } }) => {
        schema.add(
          {
            type: "object",
            properties: {
              a_string: { type: "string" },
              an_integer: { type: "integer", minimum: 1 },
            },
          },
          "test",
        );
        schema.ajv.schemas.test.schema.should.eql({
          type: "object",
          properties: {
            a_string: { type: "string" },
            an_integer: { type: "integer", minimum: 1 },
          },
        });
      });
    });

    it("`addMetadata` shall detect changes", function () {
      return nikita((action) => {
        let changed = action.tools.schema.addMetadata("toto", {
          type: "boolean",
        });
        changed.should.be.true();
        changed = action.tools.schema.addMetadata("toto", { type: "boolean" });
        changed.should.be.false();
      });
    });

    it("`addMetadata` with incorrect value", function () {
      return nikita({ $meta: "invalid" }, async (action) => {
        action.tools.schema.addMetadata("meta", { type: "boolean" });
        const error = await action.tools.schema.validate(action);
        error.code.should.eql("NIKITA_SCHEMA_VALIDATION_CONFIG");
      });
    });

    it("`addMetadata` with coercion", function () {
      return nikita({ $meta: 1 }, async (action) => {
        action.tools.schema.addMetadata("meta", {
          type: ["boolean", "number"],
          coercion: true,
        });
        const error = await action.tools.schema.validate(action);
        should(error).be.undefined();
        action.metadata.meta.should.be.true();
      });
    });

    it("ensure config is cloned", async function () {
      const config = {
        key_1: "value 1",
      };
      const metadata = {
        $definitions: {
          config: {
            type: "object",
            properties: {
              key_1: {
                type: "string",
              },
              key_2: {
                type: "string",
                default: "value 2",
              },
            },
          },
        },
      };
      await nikita.call(config, metadata, ({ config }) => {
        config.should.eql({
          key_1: "value 1",
          key_2: "value 2",
        });
      });
      config.should.eql({
        key_1: "value 1",
      });
    });
  });

  describe("`validate` error with INVALID_DEFINITION", function () {
    it("root action", function () {
      return nikita(async (action) => {
        // Defining $ref in properties is invalid
        action.metadata.definitions = {
          config: {
            type: "object",
            properties: true,
          },
        };
        const error = await action.tools.schema.validate(action);
        error.code.should.eql("NIKITA_SCHEMA_INVALID_DEFINITION");
        error.message.should.eql(
          [
            "NIKITA_SCHEMA_INVALID_DEFINITION:",
            "schema failed to compile in root action, schema is invalid:",
            "data/definitions/config/properties must be object.",
          ].join(" "),
        );
      });
    });

    it("call action", function () {
      return nikita.call(async (action) => {
        // Defining $ref in properties is invalid
        action.metadata.definitions = {
          config: {
            type: "object",
            properties: true,
          },
        };
        const error = await action.tools.schema.validate(action);
        error.code.should.eql("NIKITA_SCHEMA_INVALID_DEFINITION");
        error.message.should.eql(
          [
            "NIKITA_SCHEMA_INVALID_DEFINITION:",
            "schema failed to compile in action `call`, schema is invalid:",
            "data/definitions/config/properties must be object.",
          ].join(" "),
        );
      });
    });

    it("call with action module", function () {
      return nikita(
        {
          $tmpdir: true,
        },
        async ({ metadata: { tmpdir } }) => {
          await nikita.fs.writeFile({
            content: "module.exports = {}",
            target: `${tmpdir}/my_module.js`,
          });
          return nikita.call(`${tmpdir}/my_module.js`, async (action) => {
            // Defining $ref in properties is invalid
            action.metadata.definitions = {
              config: {
                type: "object",
                properties: true,
              },
            };
            const error = await action.tools.schema.validate(action);
            error.code.should.eql("NIKITA_SCHEMA_INVALID_DEFINITION");
            error.message = error.message.replace(
              `${tmpdir}/my_module.js`,
              "package/module",
            );
            error.message.should.eql(
              [
                "NIKITA_SCHEMA_INVALID_DEFINITION:",
                "schema failed to compile in action `call` in module package/module, schema is invalid:",
                "data/definitions/config/properties must be object.",
              ].join(" "),
            );
          });
        },
      );
    });
  });

  describe("`validate` error with VALIDATION_CONFIG", function () {
    it("root action", function () {
      return nikita({ key: "value" }, async (action) => {
        // key is a string, let's define it as an integer
        action.metadata.definitions = {
          config: {
            type: "object",
            properties: {
              key: { type: "integer" },
            },
          },
        };
        const error = await action.tools.schema.validate(action);
        error.code.should.eql("NIKITA_SCHEMA_VALIDATION_CONFIG");
        error.message.should.eql(
          [
            "NIKITA_SCHEMA_VALIDATION_CONFIG:",
            "one error was found in the configuration of root action:",
            '#/definitions/config/properties/key/type config/key must be integer, type is "integer".',
          ].join(" "),
        );
      });
    });

    it("call action", function () {
      return nikita.call({ key: "value" }, async (action) => {
        // key is a string, let's define it as an integer
        action.metadata.definitions = {
          config: {
            type: "object",
            properties: {
              key: { type: "integer" },
            },
          },
        };
        const error = await action.tools.schema.validate(action);
        error.code.should.eql("NIKITA_SCHEMA_VALIDATION_CONFIG");
        error.message.should.eql(
          [
            "NIKITA_SCHEMA_VALIDATION_CONFIG:",
            "one error was found in the configuration of action `call`:",
            "#/definitions/config/properties/key/type config/key must be integer,",
            'type is "integer".',
          ].join(" "),
        );
      });
    });

    it("call with action module", function () {
      return nikita(
        {
          $tmpdir: true,
        },
        async ({ metadata: { tmpdir } }) => {
          await nikita.fs.writeFile({
            content: "module.exports = {}",
            target: `${tmpdir}/my_module.js`,
          });
          return nikita.call(
            `${tmpdir}/my_module.js`,
            { key: "value" },
            async (action) => {
              // key is a string, let's define it as an integer
              action.metadata.definitions = {
                config: {
                  type: "object",
                  properties: {
                    key: { type: "integer" },
                  },
                },
              };
              const error = await action.tools.schema.validate(action);
              error.code.should.eql("NIKITA_SCHEMA_VALIDATION_CONFIG");
              error.message = error.message.replace(
                `${tmpdir}/my_module.js`,
                "package/module",
              );
              error.message.should.eql(
                [
                  "NIKITA_SCHEMA_VALIDATION_CONFIG:",
                  "one error was found in the configuration of action `call`",
                  "in module package/module:",
                  "#/definitions/config/properties/key/type config/key must be integer,",
                  'type is "integer".',
                ].join(" "),
              );
            },
          );
        },
      );
    });

    it("enforce unevaluatedProperty on config", function () {
      return nikita
        .call(
          {
            $definitions: {
              config: {
                type: "object",
                properties: {
                  valid_key: { type: "string" },
                },
              },
            },
            valid_key: "ok",
            invalid_key: "ko",
          },
          () => {},
        )
        .should.be.rejectedWith(
          [
            "NIKITA_SCHEMA_VALIDATION_CONFIG:",
            "one error was found in the configuration of action `call`:",
            "#/properties/config/unevaluatedProperties config must NOT have unevaluated properties,",
            'unevaluatedProperty is "invalid_key".',
          ].join(" "),
        );
    });
  });
});
