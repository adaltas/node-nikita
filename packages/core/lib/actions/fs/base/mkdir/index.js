// Dependencies
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" with { type: "json" };

const errors = {
  NIKITA_FS_MKDIR_TARGET_EEXIST: ({ config }) =>
    utils.error(
      "NIKITA_FS_MKDIR_TARGET_EEXIST",
      [
        "fail to create a directory,",
        "one already exists,",
        `location is ${JSON.stringify(config.target)}.`,
      ],
      {
        error_code: "EEXIST",
        errno: -17,
        path: config.target_tmp || config.target, // Native Node.js api doesn't provide path
        syscall: "mkdir",
      }
    ),
};

// Action
export default {
  handler: async function ({ config }) {
    if (typeof config.mode === "number") {
      // Convert mode into a string
      config.mode = config.mode.toString(8).slice(-4);
    }
    try {
      return await this.execute(
        [
          `[ -d '${config.target}' ] && exit 17`,
          [
            "install",
            config.mode && `-m '${config.mode}'`,
            config.uid && `-o '${config.uid}'`,
            config.gid && `-g '${config.gid}'`,
            `-d '${config.target}'`,
          ].filter(Boolean).join(" "),
        ].join("\n")
      );
    } catch (error) {
      if (error.exit_code === 17) {
        error = errors.NIKITA_FS_MKDIR_TARGET_EEXIST({
          config: config,
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
