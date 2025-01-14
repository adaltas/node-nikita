// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // note, getting the volume to make sure it exists
    const { $status: volumeExists, volume } =
      await this.incus.storage.volume.get({
        pool: config.pool,
        name: config.name,
        type: config.type,
      });
    if (!volumeExists) {
      throw new Error(
        `NIKITA_INCUS_VOLUME_ATTACH: volume ${JSON.stringify(config.name)} does not exist.`,
      );
    }
    // note, getting the container to make sure it exists
    const { $status: containerExists, container } = await this.incus.info(
      config.container,
      { $relax: true },
    );
    if (!containerExists) {
      throw new Error(
        `NIKITA_INCUS_VOLUME_ATTACH: container ${JSON.stringify(config.container)} does not exist.`,
      );
    }
    switch (container.type) {
      case "virtual-machine":
        if (volume.content_type === "filesystem") {
          throw new Error(
            `Type: ${container.type} can only mount block type volumes.`,
          );
        }
        break;
      case "container":
        if (volume.content_type === "block") {
          throw new Error(
            `Type: ${container.type} can only mount filesystem type volumes.`,
          );
        }
    }
    if (volume.content_type === "filesystem" && config.path == null) {
      throw new Error(
        "Missing requirement: Path is required for filesystem type volumes.",
      );
    }
    const { $status } = await this.incus.query({
      path: `/1.0/instances/${config.container}`,
      request: "PATCH",
      data: {
        devices: {
          [`${config.device}`]: {
            pool: config.pool,
            source: config.name,
            type: "disk",
            path: config.path != null ? config.path : null,
          },
        },
      },
      wait: true,
      format: "string",
      code: [0, 1],
    });
    return {
      $status: $status,
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
