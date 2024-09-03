// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

const errors = {
  NIKITA_FS_COPY_TARGET_ENOENT: ({ config, error }) =>
    utils.error(
      "NIKITA_FS_COPY_TARGET_ENOENT",
      [
        "target parent directory does not exists or is not a directory,",
        `got ${JSON.stringify(config.target)}`,
      ],
      {
        exit_code: error.exit_code,
        errno: -2,
        syscall: "open",
        path: config.target,
      },
    ),
};

// Action
export default {
  handler: async function ({ config }) {
    try {
      return await this.execute(dedent`
        [ ! -d \`dirname "${config.target}"\` ] && exit 2
        cp ${config.source} ${config.target}
      `);
    } catch (error) {
      if (error.exit_code === 2) {
        throw errors.NIKITA_FS_COPY_TARGET_ENOENT({
          config: config,
          error: error,
        });
      }
      throw error;
    }
  },
  metadata: {
    argument_to_config: "target",
    log: false,
    raw_output: true,
    definitions: definitions,
  },
};
