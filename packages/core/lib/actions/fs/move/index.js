// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    const { exists } = await this.fs.exists(config.target);
    if (!exists) {
      log("WARN", `Rename ${config.source} to ${config.target}`);
      await this.fs.rename({
        source: config.source,
        target: config.target,
      });
      return true;
    }
    if (config.force) {
      log("WARN", `Remove ${config.target}`);
      await this.fs.remove({
        target: config.target,
      });
      log("WARN", `Rename ${config.source} to ${config.target}`);
      await this.fs.rename({
        source: config.source,
        target: config.target,
      });
      return true;
    }
    if (!config.target_md5) {
      log("DEBUG", "Get target md5");
      const { hash } = await this.fs.hash(config.target);
      log("INFO", 'Destination md5 is "hash"');
      config.target_md5 = hash;
    }
    if (!config.source_md5) {
      log("DEBUG", "Get source md5");
      const { hash } = await this.fs.hash(config.source);
      log("INFO", 'Source md5 is "hash"');
      config.source_md5 = hash;
    }
    if (config.source_md5 === config.target_md5) {
      log("WARN", `Remove ${config.source}`);
      await this.fs.remove({
        target: config.source,
      });
      return false;
    }
    log("WARN", `Remove ${config.target}`);
    await this.fs.remove({
      target: config.target,
    });
    log("WARN", `Rename ${config.source} to ${config.target}`);
    await this.fs.rename({
      source: config.source,
      target: config.target,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
