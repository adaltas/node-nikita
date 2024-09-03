// Dependencies
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

const errors = {
  NIKITA_FS_TARGET_INVALID: ({ config, err }) =>
    utils.error(
      "NIKITA_FS_TARGET_INVALID",
      [
        "the target location is absolute",
        "but this is not suported in SSH mode,",
        "you must provide an absolute path or the cwd option,",
        `got ${JSON.stringify(config.target)}`,
      ],
      {
        exit_code: err.exit_code,
        errno: -2,
        syscall: "rmdir",
        path: config.target,
      },
    ),
};

// Action
export default {
  handler: async function ({ config, tools: { path }, ssh }) {
    // Normalization
    config.target =
      config.cwd ?
        path.resolve(config.cwd, config.target)
      : path.normalize(config.target);
    if (ssh && !path.isAbsolute(config.target)) {
      throw errors.NIKITA_FS_TARGET_INVALID({
        config: config,
      });
    }
    // Real work
    await this.fs.createWriteStream({
      target: config.target,
      flags: config.flags,
      mode: config.mode,
      stream: function (ws) {
        ws.write(config.content);
        ws.end();
      },
    });
  },
  metadata: {
    argument_to_config: "target",
    log: false,
    raw_output: true,
    definitions: definitions,
  },
};
