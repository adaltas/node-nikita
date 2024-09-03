// Dependencies
import fs from "ssh2-fs";
import exec from "ssh2-exec/promises";
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

const errors = {
  NIKITA_FS_CRS_NO_EVENT_HANDLER: () =>
    utils.error("NIKITA_FS_CRS_NO_EVENT_HANDLER", [
      "unable to consume the readable stream,",
      'one of the "on_readable" or "stream"',
      "hooks must be provided",
    ]),
  NIKITA_FS_CRS_TARGET_ENOENT: ({ error, config }) =>
    utils.error(
      "NIKITA_FS_CRS_TARGET_ENOENT",
      [
        "fail to read a file because it does not exist,",
        !config.target_tmp ?
          `location is ${JSON.stringify(config.target)}.`
        : `location is ${JSON.stringify(config.target_tmp)} (temporary file, target is ${JSON.stringify(config.target)}).`,
      ],
      {
        errno: error.errno,
        syscall: error.syscall,
        path: error.path,
      },
    ),
  NIKITA_FS_CRS_TARGET_EISDIR: ({ error, config }) =>
    utils.error(
      "NIKITA_FS_CRS_TARGET_EISDIR",
      [
        "fail to read a file because it is a directory,",
        !config.target_tmp ?
          `location is ${JSON.stringify(config.target)}.`
        : `location is ${JSON.stringify(config.target_tmp)} (temporary file, target is ${JSON.stringify(config.target)}).`,
      ],
      {
        errno: error.errno,
        syscall: error.syscall,
        path: config.target_tmp || config.target, // Native Node.js api doesn't provide path
      },
    ),
  NIKITA_FS_CRS_TARGET_EACCES: ({ error, config }) =>
    utils.error(
      "NIKITA_FS_CRS_TARGET_EACCES",
      [
        "fail to read a file because permission was denied,",
        !config.target_tmp ?
          `location is ${JSON.stringify(config.target)}.`
        : `location is ${JSON.stringify(config.target_tmp)} (temporary file, target is ${JSON.stringify(config.target)}).`,
      ],
      {
        errno: error.errno,
        syscall: error.syscall,
        path: config.target_tmp || config.target, // Native Node.js api doesn't provide path
      },
    ),
};

// ## Exports
export default {
  handler: async function ({ config, metadata, ssh, tools: { path, log } }) {
    const sudo = function (cmd) {
      if (config.sudo) {
        return `sudo ${cmd}`;
      } else {
        return `${cmd}`;
      }
    };
    // Normalization
    config.target =
      config.cwd ?
        path.resolve(config.cwd, config.target)
      : path.normalize(config.target);
    if (ssh && !path.isAbsolute(config.target)) {
      throw Error(
        `Non Absolute Path: target is ${JSON.stringify(config.target)}, SSH requires absolute paths, you must provide an absolute path in the target or the cwd option`,
      );
    }
    if (!(config.on_readable || config.stream)) {
      throw errors.NIKITA_FS_CRS_NO_EVENT_HANDLER();
    }
    // In sudo mode, we can't be sure the user has the permission to open a
    // readable stream on the target file, so we create a copy with the correct
    // permission
    if (config.sudo) {
      if (config.target_tmp == null) {
        config.target_tmp = `${metadata.tmpdir}/${utils.string.hash(config.target)}`;
      }
    }
    // Guess current username
    const whoami = utils.os.whoami({
      ssh: ssh,
    });
    try {
      if (config.target_tmp) {
        await exec(
          ssh,
          [
            sudo(`[ ! -f '${config.target}' ] && exit 0`),
            sudo(`cp '${config.target}' '${config.target_tmp}'`),
            sudo(`chown '${whoami}' '${config.target_tmp}'`),
          ].join("\n"),
        );
        log("INFO", "Placing original file in temporary path before reading");
      }
    } catch (error) {
      log("ERROR", "Failed to place original file in temporary path");
      throw error;
    }
    // Read the stream
    log("DEBUG", `Reading file ${config.target_tmp || config.target}`);
    let { promise, resolve, reject } = utils.promise.withResolvers();
    const rs = await fs.createReadStream(
      ssh,
      config.target_tmp || config.target,
    );
    if (config.on_readable) {
      rs.on("readable", function () {
        return config.on_readable(rs);
      });
    } else {
      config.stream(rs);
    }
    rs.on("error", function (error) {
      if (error.code === "ENOENT") {
        error = errors.NIKITA_FS_CRS_TARGET_ENOENT({
          config: config,
          error: error,
        });
      } else if (error.code === "EISDIR") {
        error = errors.NIKITA_FS_CRS_TARGET_EISDIR({
          config: config,
          error: error,
        });
      } else if (error.code === "EACCES") {
        error = errors.NIKITA_FS_CRS_TARGET_EACCES({
          config: config,
          error: error,
        });
      }
      reject(error);
    });
    rs.on("end", resolve);
    return promise;
  },
  hooks: {
    on_action: {
      after: ["@nikitajs/core/plugins/execute"],
      before: [
        "@nikitajs/core/plugins/metadata/schema",
        "@nikitajs/core/plugins/metadata/tmpdir",
      ],
      handler: async function ({ config, metadata, tools: { find } }) {
        if (config.sudo == null) {
          config.sudo = await find(function ({ metadata: { sudo } }) {
            return sudo;
          });
        }
        if (config.sudo) {
          metadata.tmpdir = {
            sudo: false,
          };
        }
      },
    },
  },
  metadata: {
    argument_to_config: "target",
    log: false,
    raw_output: true,
    definitions: definitions,
  },
};
