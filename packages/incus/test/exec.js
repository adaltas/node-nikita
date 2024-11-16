import nikita from "@nikitajs/core";
import utils from "@nikitajs/core/utils";
import test from "./test.coffee";
import mochaThey from "mocha-they";
const they = mochaThey(test.config);

describe("incus.exec", function () {
  if (!test.tags.incus) return;

  describe("schema", function () {
    it("extends nikita.execute using `code`", function () {
      return nikita.incus
        .exec({
          container: "fake",
          command: "whoami",
          code: function () {},
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
          message: new RegExp(
            utils.regexp.escape(
              "action `incus.exec`: #/properties/code/type config/code must be",
            ),
          ),
        });
    });
  });

  they("a command with pipe inside", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", function () {
          return this.incus.delete("nikita-exec-1", { force: true });
        });
        await this.clean();
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          container: "nikita-exec-1",
          start: true,
        });
        const { $status, stdout } = await this.incus.exec({
          container: "nikita-exec-1",
          command: "cat /etc/os-release | egrep ^ID=",
        });
        stdout.trim().should.eql("ID=alpine");
        $status.should.be.true();
        await this.clean();
      },
    );
  });

  describe("option `shell`", function () {
    they("default to shell", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-exec-2", { force: true });
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-exec-2",
            start: true,
          });
          const { stdout } = await this.incus.exec({
            container: "nikita-exec-2",
            command: "echo $0",
            trim: true,
          });
          stdout.should.eql("sh");
          await this.clean();
        },
      );
    });

    they("set to bash", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-exec-3", { force: true });
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-exec-3",
            start: true,
          });
          await this.incus.exec({
            $$: { retry: 3, sleep: 200 },
            container: "nikita-exec-3",
            command: "apk add bash",
          });
          const { stdout } = await this.incus.exec({
            container: "nikita-exec-3",
            command: "echo $0",
            shell: "bash",
            trim: true,
          });
          stdout.should.eql("bash");
          await this.clean();
        },
      );
    });
  });

  describe("option `trap`", function () {
    they("is enabled", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-exec-4", { force: true });
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-exec-4",
            start: true,
          });
          await this.incus
            .exec({
              container: "nikita-exec-4",
              trap: true,
              command: "false\ntrue",
            })
            .should.be.rejectedWith({
              exit_code: 1,
            });
          await this.clean();
        },
      );
    });

    they("is disabled", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-exec-5", { force: true });
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-exec-5",
            start: true,
          });
          const { $status, code } = await this.incus.exec({
            container: "nikita-exec-5",
            trap: false,
            command: "false\ntrue",
          });
          $status.should.be.true();
          code.should.eql(0);
          await this.clean();
        },
      );
    });
  });

  describe("option `env`", function () {
    they("pass multiple variables", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-exec-6", { force: true });
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-exec-6",
            start: true,
          });
          const { stdout } = await this.incus.exec({
            container: "nikita-exec-6",
            env: {
              ENV_VAR_1: "value 1",
              ENV_VAR_2: "value 1",
            },
            command: "env",
          });
          stdout
            .split("\n")
            .filter(function (line) {
              return /^ENV_VAR_/.test(line);
            })
            .should.eql(["ENV_VAR_1=value 1", "ENV_VAR_2=value 1"]);
          await this.clean();
        },
      );
    });
  });

  describe("option `user`", function () {
    they("non root user", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-exec-7", { force: true });
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-exec-7",
            start: true,
          });
          await this.incus.exec({
            container: "nikita-exec-7",
            command: "adduser --uid 1234 --disabled-password nikita",
          });
          const { stdout } = await this.incus.exec({
            container: "nikita-exec-7",
            user: 1234,
            command: "whoami",
            trim: true,
          });
          stdout.should.eql("nikita");
          await this.clean();
        },
      );
    });
  });

  describe("option `cwd`", function () {
    they("change directory", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return this.incus.delete("nikita-exec-8", { force: true });
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-exec-8",
            start: true,
          });
          const { stdout } = await this.incus.exec({
            container: "nikita-exec-8",
            cwd: "/bin",
            command: "pwd",
            trim: true,
          });
          stdout.should.eql("/bin");
          await this.clean();
        },
      );
    });
  });
});
