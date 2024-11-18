import nikita from "@nikitajs/core";
import test from "./test.js";
import mochaThey from "mocha-they";
const they = mochaThey(test.config);

describe("incus.list", function () {
  if (!test.tags.incus) return;

  they("list all instances", function ({ ssh }) {
    return nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.delete("nikita-list-c1", { force: true });
          await this.incus.delete("nikita-list-vm1", { force: true });
        });
        await this.clean();
        await this.incus.init({
          image: `images:${test.images.alpine}`,
          name: "nikita-list-c1",
        });
        await this.incus.init({
          $if: test.tags.incus_vm,
          image: `images:${test.images.alpine}`,
          name: "nikita-list-vm1",
          vm: true,
        });
        await this.wait({ time: 200 });
        await this.incus.list().then(({ $status, instances }) => {
          instances = instances.map((instance) => instance.name);
          $status.should.be.true();
          instances.should.containEql("nikita-list-c1");
          if (test.tags.incus_vm) {
            instances.should.containEql("nikita-list-vm1");
          }
        });
        await this.clean();
      },
    );
  });

  describe("option `type`", function () {
    they("filter containers", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return Promise.all([
              this.incus.delete("nikita-list-c1", { force: true }),
              this.incus.delete("nikita-list-vm1", { force: true }),
            ]);
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-list-c1",
          });
          await this.incus.init({
            $if: test.tags.incus_vm,
            image: `images:${test.images.alpine}`,
            name: "nikita-list-vm1",
            vm: true,
          });
          const { $status, instances } = await this.incus.list({
            type: "container",
          });
          $status.should.be.true();
          const instanceNames = instances.map((instance) => instance.name);
          instanceNames.should.containEql("nikita-list-c1");
          if (test.tags.incus_vm) {
            instanceNames.should.not.containEql("nikita-list-vm1");
          }
          await this.clean();
        },
      );
    });

    they("filter virtual-machines", function ({ ssh }) {
      return nikita(
        {
          $ssh: ssh,
        },
        async function ({ registry }) {
          registry.register("clean", function () {
            return Promise.all([
              this.incus.delete("nikita-list-c1", { force: true }),
              this.incus.delete("nikita-list-vm1", { force: true }),
            ]);
          });
          await this.clean();
          await this.incus.init({
            image: `images:${test.images.alpine}`,
            name: "nikita-list-c1",
          });
          await this.incus.init({
            $if: test.tags.incus_vm,
            image: `images:${test.images.alpine}`,
            name: "nikita-list-vm1",
            vm: true,
          });
          const { $status, instances } = await this.incus.list({
            type: "virtual-machine",
          });
          $status.should.be.true();
          const instanceNames = instances.map((instance) => instance.name);
          instanceNames.should.not.containEql("nikita-list-c1");
          if (test.tags.incus_vm) {
            instanceNames.should.containEql("nikita-list-vm1");
          }
          await this.clean();
        },
      );
    });
  });
});
