import nikita from "@nikitajs/core";
import utils from "@nikitajs/core/utils";
import test from "../../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config.filter(({ ssh }) => !!ssh));

describe("actions.ssh.open", function () {
  describe("schema", function () {
    if (!test.tags.api) return;

    they("config.host", function ({ ssh }) {
      return nikita.ssh
        .open({ ...ssh, host: "_invalid_", debug: undefined })
        .should.be.rejectedWith({ code: "NIKITA_SCHEMA_VALIDATION_CONFIG" });
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
