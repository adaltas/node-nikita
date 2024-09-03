// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    // Saves image to local tmp path, than copy it
    log({
      message: `Extracting image ${config.output} to file:${config.image}`,
      level: "INFO",
    });
    await this.docker.tools.execute({
      command: [
        `save -o ${config.output} ${config.image}`,
        config.tag != null ? `:${config.tag}` : void 0,
      ].join(""),
    });
  },
  hooks: {
    on_action: function ({ config }) {
      return config.output != null ?
          config.output
        : (config.output = config.target);
    },
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
