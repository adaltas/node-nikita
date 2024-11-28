import nikita from "@nikitajs/core";
import test from "../../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(test.config.filter(({ ssh }) => !!ssh));

describe("actions.ssh.close", function () {
  if (!test.tags.ssh) return;

  describe("provided connection", function () {
    they("status is true with a connection", function ({ ssh }) {
      return nikita(function () {
        return this.ssh.open(ssh).then(({ ssh }) => {
          return this.ssh
            .close({ ssh: ssh })
            .should.be.finally.containEql({ $status: true });
        });
      });
    });

    they("status is false without a connection", function ({ ssh }) {
      return nikita(function () {
        return this.ssh.open(ssh).then(({ ssh }) => {
          return this.ssh.close({ ssh: ssh }).then(() => {
            return this.ssh
              .close({ ssh: ssh })
              .should.be.finally.containEql({ $status: false });
          });
        });
      });
    });

    it("error if no connection to close", function () {
      return nikita.ssh
        .close({
          ssh: undefined,
        })
        .should.be.rejectedWith({
          code: "NIKITA_SSH_CLOSE_NO_CONN",
        });
    });
  });

  describe("sibling connection", function () {
    they("search for sibling", function ({ ssh }) {
      return nikita(function () {
        return this.ssh.open(ssh).then(() => {
          return this.ssh
            .close()
            .should.be.finally.containEql({ $status: true });
        });
      });
    });
  });
});
