import nikita from "@nikitajs/core";
import utils from "@nikitajs/core/utils";
import test from "../../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config.filter(({ ssh }) => !!ssh));

describe("actions.ssh.open", function () {
  describe("validation", function () {
    if (!test.tags.api) return;

    they("schema config.host", function ({ ssh }) {
      return nikita.ssh
        .open({ ...ssh, host: "_invalid_" })
        .should.be.rejectedWith({ code: "NIKITA_SCHEMA_VALIDATION_CONFIG" });
    });

    they("private key not found", function ({ ssh }) {
      return nikita.ssh
        .open({ ...ssh, private_key_path: "_invalid_" })
        .should.be.rejectedWith({
          code: "NIKITA_SSH_OPEN_PRIVATE_KEY_NOT_FOUND",
        });
    });
  });

  describe("usage", function () {
    if (!test.tags.ssh) return;

    they("from config", function ({ ssh }) {
      return nikita(async function () {
        const { ssh: sshConn } = await this.ssh.open(ssh);
        utils.ssh.is(sshConn).should.be.true();
        return this.ssh.close({ ssh: sshConn });
      });
    });
  });
});
