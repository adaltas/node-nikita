import nikita from "@nikitajs/core";
import test from "../../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config.filter(({ ssh }) => !!ssh));

describe("actions.ssh.root", function () {
  if (!test.tags.posix) return;

  describe("schema", function () {
    they("config.selinux is invalid", function ({ ssh }) {
      return nikita.ssh
        .root({
          selinux: "_invalid_",
          ...ssh,
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
          message: [
            "NIKITA_SCHEMA_VALIDATION_CONFIG: multiple errors were found in the configuration of action `ssh.root`:",
            "#/definitions/config/properties/selinux/oneOf config/selinux must match exactly one schema in oneOf, passingSchemas is null;",
            '#/definitions/config/properties/selinux/oneOf/0/enum config/selinux must be equal to one of the allowed values, allowedValues is ["disabled","enforcing","permissive"];',
            '#/definitions/config/properties/selinux/oneOf/1/type config/selinux must be boolean, type is "boolean".',
          ].join(" "),
        });
    });

    they("config.selinux is valid", function ({ ssh }) {
      return nikita.ssh
        .root(
          {
            $dry: true,
            selinux: "permissive",
          },
          ssh,
        )
        .should.be.finally.containEql({ $status: false });
    });
  });
});
