import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.file.push", function () {
  describe("schema", function () {
    if (!test.tags.api) return;

    it("mode symbolic", function () {
      return nikita.incus.file
        .push({
          container: "nikita-file-push",
          target: "/root/a_file",
          content: "something",
          mode: "u=rwx",
        })
        .should.be.rejectedWith({
          code: "NIKITA_SCHEMA_VALIDATION_CONFIG",
        });
    });

    it("mode coercion", function () {
      return nikita.incus.file.push(
        {
          container: "nikita-file-push",
          target: "/root/a_file",
          content: "something",
          mode: "700",
        },
        ({ config }) => {
          config.mode.should.eql(0o0700);
        },
      );
    });
  });

  describe("usage", function () {
    if (!test.tags.incus) return;

    they("require openssl", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
          $tmpdir: true,
        },
        async function ({ metadata: { tmpdir }, registry }) {
          registry.register("clean", async function () {
            await this.incus.delete("nikita-file-push-1", { force: true });
          });
          registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-file-push-1",
              start: true,
            });
            await this.file.touch({
              target: `${tmpdir}/a_file`,
            });
            await this.incus.file
              .push({
                container: "nikita-file-push-1",
                source: `${tmpdir}/a_file`,
                target: "/root/a_file",
              })
              .should.be.rejectedWith({
                code: "NIKITA_INCUS_FILE_PUSH_MISSING_OPENSSL",
              });
          });
          try {
            await this.clean();
            await this.test();
          } finally {
            await this.clean();
          }
        },
      );
    });

    they("a new file", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
          $tmpdir: true,
        },
        async function ({ metadata: { tmpdir }, registry }) {
          await registry.register("clean", async function () {
            await this.incus.delete({
              container: "nikita-file-push-2",
              force: true,
            });
            await this.incus.network.delete({
              name: "nktincuspub",
            });
          });
          await registry.register("test", async function () {
            await this.incus.network({
              name: "nktincuspub",
              properties: {
                "ipv4.address": "10.10.40.1/24",
                "ipv4.nat": true,
                "ipv6.address": "none",
              },
            });
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-file-push-2",
              start: true,
            });
            await this.incus.network.attach({
              container: "nikita-file-push-2",
              name: "nktincuspub",
            });
            await this.incus.exec({
              $retry: 100,
              $wait: 200,
              container: "nikita-file-push-2",
              command: "apk add openssl",
            });
            await this.file({
              target: `${tmpdir}/a_file`,
              content: "something",
            });
            const { $status } = await this.incus.file.push({
              container: "nikita-file-push-2",
              source: `${tmpdir}/a_file`,
              target: "/root/a_file",
            });
            $status.should.be.true();
            const { $status: exists } = await this.incus.file.exists({
              container: "nikita-file-push-2",
              target: "/root/a_file",
            });
            exists.should.be.true();
          });

          try {
            await this.clean();
            await this.test();
          } finally {
            await this.clean();
          }
        },
      );
    });

    they("the same file", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
          $tmpdir: true,
        },
        async function ({ metadata: { tmpdir }, registry }) {
          registry.register("clean", async function () {
            await this.incus.delete("nikita-file-push-3", { force: true });
          });
          registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-file-push-3",
              start: true,
            });
            await this.incus.exec({
              $$: { retry: 3, sleep: 200 },
              container: "nikita-file-push-3",
              command: "apk add openssl",
            });
            await this.file({
              target: `${tmpdir}/a_file`,
              content: "something",
            });
            await this.incus.file.push({
              container: "nikita-file-push-3",
              source: `${tmpdir}/a_file`,
              target: "/root/a_file",
            });
            const { $status } = await this.incus.file.push({
              container: "nikita-file-push-3",
              source: `${tmpdir}/a_file`,
              target: "/root/a_file",
            });
            $status.should.be.false();
          });
          try {
            await this.clean();
            await this.test();
          } finally {
            await this.clean();
          }
        },
      );
    });
  });

  describe("content", function () {
    if (!test.tags.incus) return;

    they("a new file", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete("nikita-file-push-4", { force: true });
          });
          registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-file-push-4",
              start: true,
            });
            await this.incus.exec({
              $$: { retry: 3, sleep: 200 },
              container: "nikita-file-push-4",
              command: "apk add openssl",
            });
            const { $status } = await this.incus.file.push({
              container: "nikita-file-push-4",
              target: "/root/a_file",
              content: "something",
            });
            $status.should.be.true();
            const { stdout } = await this.incus.exec({
              container: "nikita-file-push-4",
              command: "cat /root/a_file",
            });
            stdout.trim().should.eql("something");
          });
          try {
            await this.clean();
            await this.test();
          } finally {
            await this.clean();
          }
        },
      );
    });

    they("the same file", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete("nikita-file-push-5", { force: true });
          });
          registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-file-push-5",
              start: true,
            });
            await this.incus.exec({
              $$: { retry: 3, sleep: 200 },
              container: "nikita-file-push-5",
              command: "apk add openssl",
            });
            await this.incus.file.push({
              container: "nikita-file-push-5",
              target: "/root/a_file",
              content: "something",
            });
            const { $status } = await this.incus.file.push({
              container: "nikita-file-push-5",
              target: "/root/a_file",
              content: "something",
            });
            $status.should.be.false();
          });
          try {
            await this.clean();
            await this.test();
          } finally {
            await this.clean();
          }
        },
      );
    });
  });

  describe("mode", function () {
    if (!test.tags.incus) return;

    they("absolute mode", async function ({ ssh }) {
      await nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", async function () {
            await this.incus.delete("nikita-file-push-6", { force: true });
          });
          registry.register("test", async function () {
            await this.incus.init({
              image: `images:${test.images.alpine}`,
              container: "nikita-file-push-6",
              start: true,
            });
            await this.incus.exec({
              $$: { retry: 3, sleep: 200 },
              container: "nikita-file-push-6",
              command: "apk add openssl",
            });
            await this.incus.file.push({
              container: "nikita-file-push-6",
              target: "/root/a_file",
              content: "something",
              mode: 700,
            });
            const { stdout } = await this.incus.exec({
              container: "nikita-file-push-6",
              command: "ls -l /root/a_file",
              trim: true,
            });
            stdout.should.match(/^-rwx------\s+/);
          });
          try {
            await this.clean();
            await this.test();
          } finally {
            await this.clean();
          }
        },
      );
    });
  });
});
