import nikita from "@nikitajs/core";
import test from "../../test.coffee";

describe("plugins.tools.schema.$ref", function () {
  if (!test.tags.api) return;

  it("malformed ref URI", function () {
    return nikita
      .call(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                an_object: { $ref: "malformed/uri" },
              },
            },
          },
          an_object: "abc",
        },
        () => {},
      )
      .should.be.rejectedWith(
        [
          "NIKITA_SCHEMA_MALFORMED_URI:",
          "uri must start with a valid protocol",
          'such as "module://" or "registry://",',
          'got "malformed/uri".',
        ].join(" "),
      );
  });

  it("invalid ref definition", function () {
    return nikita.registry
      .register({
        namespace: ["test", "schema"],
        action: {
          metadata: {
            definitions: {
              config: {
                type: "object",
                properties: {
                  an_integer: { type: "integer" },
                },
              },
            },
          },
          handler: () => {},
        },
      })
      .call({
        $definitions: {
          config: {
            type: "object",
            properties: {
              an_object: { $ref: "registry://test/schema#/definitions/config" },
            },
          },
        },
        $handler: () => {},
        an_object: { an_integer: "abc" },
      })
      .should.be.rejectedWith(
        [
          "NIKITA_SCHEMA_VALIDATION_CONFIG:",
          "one error was found in the configuration of action `call`:",
          "registry://test/schema#/definitions/config/properties/an_integer/type",
          "config/an_object/an_integer must be integer,",
          'type is "integer".',
        ].join(" "),
      );
  });

  it("invalid protocol", function () {
    return nikita
      .call({
        $definitions: {
          config: {
            type: "object",
            properties: {
              a_key: { $ref: "invalid://protocol" },
            },
          },
        },
        $handler: () => {},
        a_key: true,
      })
      .should.be.rejectedWith(
        [
          "NIKITA_SCHEMA_UNSUPPORTED_PROTOCOL:",
          "the $ref instruction reference an unsupported protocol,",
          'got "invalid:".',
        ].join(" "),
      );
  });

  describe("$ref relative with `#/definitions`", function () {
    it("valid", function () {
      return nikita.call(
        {
          $definitions: {
            config: {
              type: "object",
              properties: {
                a_source: { $ref: "#/definitions/config/properties/a_target" },
                a_target: {
                  type: "object",
                  properties: {
                    an_integer: { type: ["integer", "string"], coercion: true },
                    a_default: { type: "string", default: "hello" },
                  },
                },
              },
            },
          },
          a_source: { an_integer: "123" },
        },
        function (action) {
          return action.config.should.eql({
            a_source: { an_integer: 123, a_default: "hello" },
          });
        },
      );
    });
  });

  describe("$ref with `module:` protocol", function () {
    it("invalid module ref location", function () {
      return nikita
        .call(
          {
            an_object: { an_integer: "abc" },
            $definitions: {
              config: {
                type: "object",
                properties: {
                  an_object: { $ref: "module://invalid/action" },
                },
              },
            },
          },
          () => {},
        )
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_INVALID_MODULE",
          message:
            /NIKITA_SCHEMA_INVALID_MODULE: the module location is not resolvable, module name is "invalid\/action", error message is ".*"\./,
        });
    });

    it("valid ref location", function () {
      return nikita(
        {
          $tmpdir: true,
        },
        async function ({ metadata: { tmpdir } }) {
          await this.fs.writeFile({
            target: `${tmpdir}/a_module.js`,
            content: `
            module.exports = {
              metadata: {
                definitions: {
                  config: {
                    type: 'object',
                    properties: {
                      an_integer: { type: ["integer", "string"], coercion: true },
                      a_default: { type: "string", default: "hello" }
                    }
                  }
                }
              },
              handler: () => 'ok'
            }
          `,
          });
          const { config } = await this.call(
            {
              $definitions: {
                config: {
                  type: "object",
                  properties: {
                    a_source: {
                      $ref: `module://${tmpdir}/a_module.js#/definitions/config`,
                    },
                  },
                },
              },
              a_source: { an_integer: "123" },
            },
            ({ config }) => ({ config }),
          );
          return config.should.eql({
            a_source: { an_integer: 123, a_default: "hello" },
          });
        },
      );
    });
  });

  describe("$ref with `registry:` protocol", function () {
    it("invalid registry ref location", function () {
      return nikita
        .call(
          {
            an_object: { an_integer: "abc" },
            $definitions: {
              config: {
                type: "object",
                properties: {
                  an_object: { $ref: "registry://invalid/action" },
                },
              },
            },
          },
          () => {},
        )
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_UNREGISTERED_ACTION",
          message: [
            "NIKITA_SCHEMA_UNREGISTERED_ACTION:",
            "the action is not registered inside the Nikita registry,",
            'action namespace is "invalid.action".',
          ].join(" "),
        });
    });

    it("valid ref location", function () {
      return nikita.registry
        .register({
          namespace: ["test", "schema"],
          action: {
            metadata: {
              definitions: {
                config: {
                  type: "object",
                  properties: {
                    an_integer: { type: ["integer", "string"], coercion: true },
                    a_default: { type: "string", default: "hello" },
                  },
                },
              },
            },
            handler: () => {},
          },
        })
        .call(
          {
            $definitions: {
              config: {
                type: "object",
                properties: {
                  a_source: {
                    $ref: "registry://test/schema#/definitions/config",
                  },
                },
              },
            },
            a_source: { an_integer: "123" },
          },
          function (action) {
            return action.config.should.eql({
              a_source: { an_integer: 123, a_default: "hello" },
            });
          },
        );
    });

    it("invalid ref location", async function () {
      await nikita
        .call(
          {
            $definitions: {
              config: {
                type: "object",
                properties: {
                  an_object: { $ref: "registry://invalid/action" },
                },
              },
            },
            an_object: { an_integer: "abc" },
          },
          () => {},
        )
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_UNREGISTERED_ACTION",
          message: [
            "NIKITA_SCHEMA_UNREGISTERED_ACTION:",
            "the action is not registered inside the Nikita registry,",
            'action namespace is "invalid.action".',
          ].join(" "),
        });
    });
  });
});
