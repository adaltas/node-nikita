// Dependencies
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);
const esa = utils.string.escapeshellarg;

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    const { files } = await this.fs.glob(config.target);
    for (const file of files) {
      log("INFO", `Removing file ${esa(file)}.`);
      try {
        const { status } = await this.execute({
          command: [
            "rm",
            "-d", // Attempt to remove directories as well as other types of files.
            config.recursive && "-r",
            esa(file),
          ]
            .filter(Boolean)
            .join(" "),
        });
        if (status) {
          log("WARN", `File ${esa(file)} removed.`);
        }
      } catch (error) {
        if (utils.string.lines(error.stderr.trim()).length === 1) {
          error.message = [
            "failed to remove the file, got message",
            JSON.stringify(error.stderr.trim()),
          ].join(" ");
        }
        throw error;
      }
    }
    return {};
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
