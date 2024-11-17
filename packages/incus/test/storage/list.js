import nikita from "@nikitajs/core";
import test from "../test.js";
import mochaThey from "mocha-they";

const they = mochaThey(test.config);

describe("incus.storage.list", function () {
  if (!test.tags.incus) {
    return;
  }

  they("List storages", async function ({ ssh }) {
    await nikita(
      {
        $ssh: ssh,
      },
      async function ({ registry }) {
        registry.register("clean", async function () {
          await this.incus.storage.delete("nikita-storage-list-1");
        });
        registry.register("test", async function () {
          await this.incus.storage({
            name: "nikita-storage-list-1",
            driver: "zfs",
          });
          const { storages } = await this.incus.storage.list();
          const storage = storages.find(
            (storage) => storage.name === "nikita-storage-list-1",
          );
          storage.should.match({
            config: {
              size: /\d+\w+/, // eg "19GiB"
              source: (source) => source.endsWith("nikita-storage-list-1.img"),
              "zfs.pool_name": "nikita-storage-list-1",
            },
            description: "",
            driver: "zfs",
            locations: ["none"],
            name: "nikita-storage-list-1",
            status: "Created",
            used_by: [],
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
});
