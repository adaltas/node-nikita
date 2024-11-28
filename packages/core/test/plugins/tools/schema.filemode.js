import nikita from "@nikitajs/core";
import test from "../../test.coffee";

describe("plugins.tools.schema.filemode", function () {
  if (!test.tags.api) return;

  it("filemode true with string casted to octal", function () {
    return nikita.call(
      {
        $definitions: {
          config: {
            type: "object",
            properties: {
              mode: {
                type: ["integer", "string"],
                filemode: true,
              },
            },
          },
        },
        mode: "744",
      },
      function ({ config }) {
        config.mode.should.eql(0o0744);
      },
    );
  });

  it("filemode false is invalid", function () {
    return nikita
      .call({
        $definitions: {
          config: {
            type: "object",
            properties: {
              mode: {
                type: ["integer", "string"],
                filemode: false,
              },
            },
          },
        },
        mode: "744",
      })
      .should.be.rejectedWith({
        code: "NIKITA_SCHEMA_INVALID_DEFINITION",
      });
  });
});
