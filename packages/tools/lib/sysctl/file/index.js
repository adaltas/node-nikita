// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    let $status = false;
    // Read current properties
    const current = await this.tools.sysctl.file
      .read({
        $relax: true,
        target: config.target,
        comment: config.comment,
      })
      .then(({ data }) => data || {});
    // Merge user properties
    const final = {};
    if (config.merge) {
      for (const key in current) {
        final[key] = current[key];
      }
    }
    for (const key in config.properties) {
      let value = config.properties[key];
      if (value == null) {
        continue;
      }
      if (typeof value === "number") {
        value = `${value}`;
      }
      if (current[key] === value) {
        continue;
      }
      log(`Update Property: key "${key}" from "${final[key]}" to "${value}"`);
      final[key] = value;
      $status = true;
    }
    if ($status) {
      await this.file({
        target: config.target,
        backup: config.backup,
        content: Object.keys(final)
          .map((key) =>
            final[key] != null ? `${key} = ${final[key]}` : `${key}`,
          )
          .join("\n"),
      });
    }
    if (config.load && $status) {
      await this.execute(`sysctl -p ${config.target}`);
    }
  },
  metadata: {
    definitions: definitions,
  },
};
