// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    const { $status } = await this.call(async function () {
      log("DEBUG", `Check if target exists "${config.target}"`);
      const { exists } = await this.fs.exists({
        target: config.target,
      });
      if (!exists) {
        log("Destination does not exists");
      }
      return !exists;
    });
    // if the file doesn't exist, create a new one
    if ($status) {
      await this.file({
        content: "",
        target: config.target,
        mode: config.mode,
        uid: config.uid,
        gid: config.gid,
      });
    } else {
      // todo check uid/gid/mode
      // if the file exists, overwrite it using `touch` but don't update the status
      await this.execute({
        $shy: true,
        command: `touch ${config.target}`,
      });
    }
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
