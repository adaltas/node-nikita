import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

// Todo:
// - Test about the mode
// - Test about pulling a file that already exists in local directory

describe("incus.file.pull", function () {
  if (!test.tags.incus) return;

  they("require openssl", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
        $tmpdir: true,
      },
      async function ({ registry, metadata: { tmpdir } }) {
        registry.register("clean", function () {
          return this.incus.delete("nikita-file-pull-1", { force: true });
        });
        registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-file-pull-1",
            start: true,
          });
          await this.incus.start("nikita-file-pull-1");
          // pulling file from container
          await this.incus.file
            .pull({
              name: "nikita-file-pull-1",
              source: "/etc/passwd",
              target: `${tmpdir}/nikita-file-pull-1`,
            })
            .should.be.rejectedWith({
              code: "NIKITA_INCUS_FILE_PULL_MISSING_OPENSSL",
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

  they("should pull a file from a remote server", function ({ ssh }) {
    this.timeout(-1);
    return nikita(
      {
        $ssh: ssh,
        $tmpdir: true,
      },
      async function ({ metadata: { tmpdir }, registry }) {
        await registry.register("clean", async function () {
          await this.incus.delete("nikita-file-pull-2", { force: true });
          await this.incus.network.delete("nktincuspub");
        });
        await registry.register("test", async function () {
          // creating network
          await this.incus.network("nktincuspub", {
            properties: {
              "ipv4.address": "10.10.40.1/24",
              "ipv4.nat": true,
              "ipv6.address": "none",
            },
          });
          // creating a container
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-file-pull-2",
            start: true,
          });
          // attaching network
          await this.incus.network.attach({
            container: "nikita-file-pull-2",
            name: "nktincuspub",
          });
          // adding openssl for file pull
          await this.incus.exec({
            $retry: 100,
            $wait: 200, // Wait for network to be ready
            name: "nikita-file-pull-2",
            command: "apk add openssl",
          });
          await this.incus.exec({
            name: "nikita-file-pull-2",
            command: "touch file.sh && echo 'hello' > file.sh",
          });
          // pulling file from container
          await this.incus.file.pull({
            name: "nikita-file-pull-2",
            source: "/root/file.sh",
            target: `${tmpdir}/`,
          });
          // check if file exists in temp directory
          const { exists } = await this.fs.exists({
            target: `${tmpdir}/file.sh`,
          });
          exists.should.be.eql(true);
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
