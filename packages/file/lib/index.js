// Dependencies
import path from "node:path";
import utils from "@nikitajs/file/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    // Content: pass all arguments to function calls
    const context = arguments[0];
    if (config.source) {
      log("DEBUG", `Source is ${JSON.stringify(config.source)}.`);
    }
    log("DEBUG", `Write to destination ${JSON.stringify(config.target)}.`);
    if (typeof config.content === "function") {
      config.content = config.content.call(this, context);
    }
    if (config.diff == null) {
      config.diff = config.diff || !!config.stdout;
    }
    switch (config.eof) {
      case "unix":
        config.eof = "\n";
        break;
      case "mac":
        config.eof = "\r";
        break;
      case "windows":
        config.eof = "\r\n";
        break;
      case "unicode":
        config.eof = "\u2028";
    }
    let targetContent = null;
    let targetContentHash = null;
    if (config.write == null) {
      config.write = [];
    }
    if (
      config.from != null ||
      config.to != null ||
      config.match != null ||
      config.replace != null ||
      config.place_before != null
    ) {
      config.write.push({
        from: config.from,
        to: config.to,
        match: config.match,
        replace: config.replace,
        append: config.append,
        place_before: config.place_before,
      });
      config.append = false;
    }
    for (const w of config.write) {
      if (
        w.from == null &&
        w.to == null &&
        w.match == null &&
        w.replace != null
      ) {
        w.match = w.replace;
      }
    }
    // Start work
    if (config.source != null) {
      // Option "local" force to bypass the ssh
      // connection, use by the upload function
      const source = config.source || config.target;
      log(
        "DEBUG",
        `Force local source is \`${config.local ? "true" : "false"}\`.`,
      );
      const { exists } = await this.fs.exists({
        $ssh: config.local ? false : undefined,
        $sudo: config.local ? false : undefined,
        target: source,
      });
      if (!exists) {
        if (config.source) {
          throw Error(
            `Source does not exist: ${JSON.stringify(config.source)}`,
          );
        }
        config.content = "";
      }
      log("DEBUG", "Reading source.");
      ({ data: config.content } = await this.fs.readFile({
        $ssh: config.local ? false : undefined,
        $sudo: config.local ? false : undefined,
        target: source,
        encoding: config.encoding,
      }));
    } else if (config.content == null) {
      try {
        ({ data: config.content } = await this.fs.readFile({
          $ssh: config.local ? false : undefined,
          $sudo: config.local ? false : undefined,
          target: config.target,
          encoding: config.encoding,
        }));
      } catch (error) {
        if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
          throw error;
        }
        config.content = "";
      }
    }
    // Stat the target
    const targetStats = await this.call(
      {
        $raw_output: true,
      },
      async function () {
        if (typeof config.target !== "string") {
          return null;
        }
        log("DEBUG", "Stat target.");
        try {
          let { stats } = await this.fs.lstat({
            target: config.target,
          });
          if (utils.stats.isDirectory(stats.mode)) {
            throw utils.error("NIKITA_FILE_INCOHERENT_STATE", [
              "Incoherent situation,",
              "target is a directory and there is no source to guess the filename",
            ]);
          } else if (utils.stats.isSymbolicLink(stats.mode)) {
            log("INFO", "Destination is a symlink.");
            if (config.unlink) {
              await this.fs.unlink({
                target: config.target,
              });
              stats = null;
            }
          } else if (utils.stats.isFile(stats.mode)) {
            log("INFO", "Destination is a file.");
          } else {
            throw Error(`Invalid File Type Destination: ${config.target}`);
          }
          return stats;
        } catch (error) {
          switch (error.code) {
            case "NIKITA_FS_STAT_TARGET_ENOENT":
              await this.fs.mkdir({
                target: path.dirname(config.target),
                uid: config.uid,
                gid: config.gid,
                // force execution right on mkdir
                mode: config.mode ? config.mode | 0o111 : 0o755,
              });
              break;
            default:
              throw error;
          }
          return null;
        }
      },
    );
    if (config.transform) {
      // if the transform function returns null or undefined, the file is not written
      // else if transform throws an error, the error isnt caught but rather thrown
      config.content = await config.transform.call(undefined, {
        config: config,
      });
    }
    if (config.remove_empty_lines) {
      log("DEBUG", "Remove empty lines.");
      config.content = config.content.replace(
        /(\r\n|[\n\r\u0085\u2028\u2029])\s*(\r\n|[\n\r\u0085\u2028\u2029])/g,
        "$1",
      );
    }
    if (config.write.length) {
      utils.partial(config, log);
    }
    if (config.eof) {
      log("DEBUG", "Checking option eof.");
      if (config.eof === true) {
        for (let i = 0; i < config.content.length; i++) {
          const char = config.content[i];
          if (char === "\r") {
            config.eof = config.content[i + 1] === "\n" ? "\r\n" : char;
            break;
          }
          if (char === "\n" || char === "\u2028") {
            config.eof = char;
            break;
          }
        }
        if (config.eof === true) {
          config.eof = "\n";
        }
        log(
          "INFO",
          `Option eof is true, guessing as ${JSON.stringify(config.eof)}.`,
        );
      }
      if (!utils.string.endsWith(config.content, config.eof)) {
        log("INFO", "Add eof.");
        config.content += config.eof;
      }
    }
    // Read the target, compute its hash and diff its content
    if (targetStats) {
      ({ data: targetContent } = await this.fs.readFile({
        target: config.target,
        encoding: config.encoding,
      }));
      targetContentHash = utils.string.hash(targetContent);
    }
    const contentChanged =
      config.content != null ?
        targetStats == null ||
        targetContentHash !== utils.string.hash(config.content)
      : false;
    if (contentChanged) {
      const { raw, text } = utils.diff(targetContent, config.content, config);
      if (typeof config.diff === "function") {
        config.diff(text, raw);
      }
      log("INFO", text, {
        type: "diff",
      });
    }
    if (config.backup && contentChanged) {
      log("INFO", "Create backup.");
      if (config.backup_mode == null) {
        config.backup_mode = 0o0400;
      }
      const backup =
        typeof config.backup === "string" ? config.backup : `.${Date.now()}`;
      await this.fs.copy({
        $relax: "NIKITA_FS_STAT_TARGET_ENOENT",
        source: config.target,
        target: `${config.target}${backup}`,
        mode: config.backup_mode,
      });
    }
    // Call the target with the content when a function
    if (typeof config.target === "function") {
      log("INFO", "Write target with user function.");
      await config.target({
        content: config.content,
      });
    } else {
      // Ownership and permission are also handled
      // Preserved the file mode if the file exists. Otherwise,
      // delegate to fs.createWriteStream` the creation of the default
      // mode of "744".
      // https://github.com/nodejs/node/issues/1104
      // `mode` specifies the permissions to use in case a new file is created.
      if (contentChanged) {
        await this.call(async function () {
          if (config.append) {
            if (config.flags == null) {
              config.flags = "a";
            }
          }
          await this.fs.writeFile({
            target: config.target,
            flags: config.flags,
            content: config.content,
            mode: targetStats != null ? targetStats.mode : undefined,
          });
          return {
            $status: true,
          };
        });
      }
      if (config.mode) {
        await this.fs.chmod({
          target: config.target,
          stats: targetStats,
          mode: config.mode,
        });
      } else if (targetStats) {
        await this.fs.chmod({
          target: config.target,
          stats: targetStats,
          mode: targetStats.mode,
        });
      }
      // Option gid is set at runtime if target is a new file
      await this.fs.chown({
        $if: config.uid != null || config.gid != null,
        target: config.target,
        stats: targetStats,
        uid: config.uid,
        gid: config.gid,
      });
    }
  },
  hooks: {
    on_action: function ({ config }) {
      if (
        !(
          config.source ||
          config.content != null ||
          config.replace != null ||
          config.write != null
        )
      ) {
        // Validate parameters
        // TODO: try to express this in JSON schema
        throw Error("Missing source or content or replace or write");
      }
      if (config.source && config.content != null) {
        throw Error("Define either source or content");
      }
      if (config.content) {
        if (typeof config.content === "number") {
          return (config.content = `${config.content}`);
        } else if (Buffer.isBuffer(config.content)) {
          return (config.content = config.content.toString());
        }
      }
    },
  },
  metadata: {
    definitions: definitions,
  },
};
