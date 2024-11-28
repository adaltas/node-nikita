import stream from "node:stream";
import nikita from "@nikitajs/core";
import test from "../../test.coffee";

describe("plugins.tools.schema.instanceof", function () {
  if (!test.tags.api) return;

  it("Error with valid property", async function () {
    await nikita(async function ({ registry }) {
      registry.register(["test"], {
        metadata: {
          definitions: {
            config: {
              type: "object",
              properties: {
                err: {
                  instanceof: "Error",
                },
              },
            },
          },
        },
        handler: ({ config }) => config.err.message,
      });
      await this.test({
        err: new Error("catchme"),
      }).should.be.fulfilledWith("catchme");
    });
  });

  it("Error with invalid property", function () {
    return nikita(async function ({ registry }) {
      registry.register(["test"], {
        metadata: {
          definitions: {
            config: {
              type: "object",
              properties: {
                err: {
                  instanceof: "Error",
                },
              },
            },
          },
        },
        handler: ({ config }) => config.err.message,
      });
      await this.test({
        err: "catchme",
      }).should.be.rejectedWith({
        message: [
          "NIKITA_SCHEMA_VALIDATION_CONFIG:",
          "one error was found in the configuration of action `test`:",
          "#/definitions/config/properties/err/instanceof",
          'config/err must pass "instanceof" keyword validation.',
        ].join(" "),
      });
    });
  });

  it("stream with valid property", function () {
    return nikita(async function ({ registry }) {
      registry.register(["test"], {
        metadata: {
          definitions: {
            config: {
              type: "object",
              properties: {
                writable: {
                  instanceof: "stream.Writable",
                },
                readable: {
                  instanceof: "stream.Readable",
                },
              },
            },
          },
        },
        handler: () => "ok",
      });
      await this.test({
        writable: new stream.Writable(),
        readable: new stream.Readable(),
      }).should.be.fulfilledWith("ok");
    });
  });

  it("stream with invalid property", function () {
    return nikita(async function ({ registry }) {
      registry.register(["test"], {
        metadata: {
          definitions: {
            config: {
              type: "object",
              properties: {
                writable: {
                  instanceof: "stream.Writable",
                },
                readable: {
                  instanceof: "stream.Readable",
                },
              },
            },
          },
        },
        handler: ({ config }) => config.err.message,
      });
      await this.test({
        writable: "invalid",
        readable: "invalid",
      }).should.be.rejectedWith({
        message: [
          "NIKITA_SCHEMA_VALIDATION_CONFIG:",
          "multiple errors were found in the configuration of action `test`:",
          '#/definitions/config/properties/readable/instanceof config/readable must pass "instanceof" keyword validation;',
          "#/definitions/config/properties/writable/instanceof",
          'config/writable must pass "instanceof" keyword validation.',
        ].join(" "),
      });
    });
  });
});
