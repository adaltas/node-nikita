import nikita from "@nikitajs/core";
import utils from "@nikitajs/core/utils";
import test from "../test.coffee";
import mochaThey from "mocha-they";

const they = mochaThey(
  test.config.filter(function ({ ssh }) {
    return !!ssh;
  }),
);

describe("`plugins.ssh`", function () {
  if (!test.tags.ssh) return;

  describe("validation", function () {
    they("uses schema plugin", async function ({ ssh }) {
      await nikita(
        { $ssh: { ...ssh, ip: "invalid" } },
        function () {},
      ).should.be.rejectedWith(
        [
          "NIKITA_SCHEMA_VALIDATION_CONFIG:",
          "one error was found in the configuration of action `ssh.open`:",
          '#/properties/ip/format config/ip must match format "ipv4",',
          'format is "ipv4".',
        ].join(" "),
      );
    });
  });

  describe("from parent (action.ssh)", function () {
    they("from config in root action", function ({ ssh }) {
      return nikita({ $ssh: ssh }, function ({ ssh: conn }) {
        utils.ssh.compare(conn, ssh).should.be.true();
      });
    });

    they("from config in child action", function ({ ssh }) {
      return nikita({ $ssh: ssh }, function () {
        return this.call(function () {
          return this.call(function ({ ssh: conn }) {
            utils.ssh.compare(conn, ssh).should.be.true();
          });
        });
      });
    });

    they("from connection", async function ({ ssh }) {
      const { ssh: conn } = await nikita.ssh.open(ssh);
      await nikita({ $ssh: conn }, function ({ ssh: conn }) {
        return this.call(function () {
          return this.call(function () {
            utils.ssh.compare(conn, ssh).should.be.true();
          });
        });
      });
      return nikita.ssh.close({ ssh: conn });
    });

    they("local if null", function ({ ssh }) {
      return nikita({ $ssh: ssh }, function () {
        return this.call(function () {
          return this.call({ $ssh: null }, function (action) {
            (action.ssh === null).should.be.true();
            return this.call(function (action) {
              // Ensure the ssh value is propagated to children
              (action.ssh === undefined).should.be.true();
            });
          });
        });
      });
    });

    they("local if false", function ({ ssh }) {
      return nikita({ $ssh: ssh }, function () {
        return this.call(function () {
          return this.call({ $ssh: false }, function (action) {
            (action.ssh === null).should.be.true();
            return this.call(function (action) {
              // Ensure the ssh value is propagated to children
              (action.ssh === undefined).should.be.true();
            });
          });
        });
      });
    });
  });

  describe("from siblings (open/close)", function () {
    they("ssh.open", async function ({ ssh }) {
      return nikita(async function () {
        await this.ssh.open(ssh);
        try {
          const { stdout: whoami } = await this.execute({
            command: "whoami",
            trim: true,
          });
          whoami.should.eql(ssh.username);
        } finally {
          await this.ssh.close();
        }
      });
    });
  });
});
