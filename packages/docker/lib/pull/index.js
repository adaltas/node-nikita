// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // Validate
    const [name, tag] = config.image.split(":");
    config.image = name;
    if (tag && config.tag) {
      // it can be later changed to give a preference instead of error
      throw Error(
        "Tag must be specified either in the image or in the tag config",
      );
    }
    if (config.tag == null) {
      config.tag = tag || "latest";
    }
    // Check if exist
    const { $status } = await this.docker.tools.execute({
      $shy: true,
      // avoid checking when all config is true,
      // because there is no native way to list all existing tags on the registry
      $unless: config.all,
      command: [
        "images",
        `| grep '${config.image}'`,
        `| grep '${config.tag}'`,
      ].join(" "),
      code: [0, 1],
    });
    // Pull image
    await this.docker.tools.execute({
      $unless: $status,
      command: [
        "pull",
        config.all ? `-a ${config.image}` : `${config.image}:${config.tag}`,
      ].join(" "),
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
