import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.file.exists", function () {
  if (!test.tags.incus) return;

  they("when present", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.delete("nikita-file-exists-1", { force: true });
        });
        registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-file-exists-1",
            start: true,
          });
          await this.execute({
            command: "incus exec nikita-file-exists-1 -- touch /root/a_file",
          });
          const { exists } = await this.incus.file.exists({
            container: "nikita-file-exists-1",
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

  they("when missing", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.delete("nikita-file-exists-2", { force: true });
        });
        registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-file-exists-2",
            start: true,
          });
          const { exists } = await this.incus.file.exists({
            container: "nikita-file-exists-2",
            target: "/root/a_file",
          });
          exists.should.be.false();
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

  they("change of status", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.delete("nikita-file-exists-3", { force: true });
        });
        registry.register("test", async function () {
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            container: "nikita-file-exists-3",
            start: true,
          });
          // check is exists is true
          await this.incus.exec({
            container: "nikita-file-exists-3",
            command: "touch /root/a_file",
          });
          let { exists } = await this.incus.file.exists({
            container: "nikita-file-exists-3",
            target: "/root/a_file",
          });
          exists.should.be.true();
          // check is exists is false
          await this.incus.exec({
            container: "nikita-file-exists-3",
            command: "rm -f /root/a_file",
          });
          ({ exists } = await this.incus.file.exists({
            container: "nikita-file-exists-3",
            target: "/root/a_file",
          }));
          exists.should.be.false();
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
