import nikita from "@nikitajs/core";
import test from "../../test.coffee";

describe("plugins.tools.schema.boolean", function () {
  if (!test.tags.api) return;

  const definitions = {
    config: {
      type: "object",
      properties: {
        a_boolean: {
          type: "boolean",
          default: true,
        },
      },
    },
  };

  it("default value", function () {
    nikita.call({
      $definitions: definitions,
      $handler: function ({ config }) {
        config.a_boolean.should.eql(true);
      },
    });
  });

  it("default true with config `true`", function () {
    nikita.call({
      $definitions: definitions,
      a_boolean: true,
      $handler: function ({ config }) {
        config.a_boolean.should.eql(true);
      },
    });
  });

  it("default true with config `false`", function () {
    nikita.call({
      $definitions: definitions,
      a_boolean: false,
      $handler: function ({ config }) {
        config.a_boolean.should.eql(false);
      },
    });
  });
});
