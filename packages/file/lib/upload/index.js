// Dependencies
import fs from "node:fs";
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
    const algo = config.sha1 != null ? "sha1" : "md5";
    log("DEBUG", `Source is "${config.source}", target is "${config.target}"`);
    // Stat the target and redefine its path if a directory
    const stats = await this.call(
      {
        $raw_output: true,
      },
      async function () {
        try {
          const { stats } = await this.fs.stat({
            $ssh: false,
            $sudo: false,
            target: config.target,
          });
          if (utils.stats.isFile(stats.mode)) {
            // Target is a file
            return stats;
          }
          if (!utils.stats.isDirectory(stats.mode)) {
            // Target is invalid
            throw Error(
              `Invalid Target: expect a file, a symlink or a directory for ${JSON.stringify(
                config.target,
              )}`,
            );
          }
          // Target is a directory
          config.target = path.resolve(
            config.target,
            path.basename(config.source),
          );
          try {
            const { stats } = await this.fs.stat({
              $ssh: false,
              $sudo: false,
              target: config.target,
            });
            if (utils.stats.isFile(stats.mode)) {
              return stats;
            }
            throw Error(`Invalid target: ${config.target}`);
          } catch (error) {
            if (error.code === "NIKITA_FS_STAT_TARGET_ENOENT") {
              return null;
            }
            throw error;
          }
        } catch (error) {
          if (error.code === "NIKITA_FS_STAT_TARGET_ENOENT") {
            return null;
          }
          throw error;
        }
      },
    );
    // Now that we know the real name of the target, define a temporary file to write
    const stage_target = `${config.target}.${Date.now()}${Math.round(
      Math.random() * 1000,
    )}`;
    const { $status } = await this.call(async function () {
      if (!stats) {
        return true;
      }
      const { hash: hash_source } = await this.fs.hash({
        target: config.source,
        algo: algo,
      });
      const { hash: hash_target } = await this.fs.hash({
        $ssh: false,
        $sudo: false,
        target: config.target,
        algo: algo,
      });
      const match = hash_source === hash_target;
      log(
        match ?
          `Hash matches as '${hash_source}'`
        : {
            message: `Hash dont match, source is '${hash_source}' and target is '${hash_target}'`,
            level: "WARN",
          },
      );
      return !match;
    });
    if (!$status) {
      return;
    }
    await this.fs.mkdir({
      $ssh: false,
      $sudo: false,
      target: path.dirname(stage_target),
    });
    await this.fs.createReadStream({
      target: config.source,
      stream: (rs) => rs.pipe(fs.createWriteStream(stage_target)),
    });
    await this.fs.move({
      $ssh: false,
      $sudo: false,
      source: stage_target,
      target: config.target,
    });
    log({
      message: "Unstaged uploaded file",
      level: "INFO",
    });
    if (config.mode != null) {
      await this.fs.chmod({
        $ssh: false,
        $sudo: false,
        target: config.target,
        mode: config.mode,
      });
    }
    if (config.uid != null || config.gid != null) {
      await this.fs.chown({
        $ssh: false,
        $sudo: false,
        target: config.target,
        uid: config.uid,
        gid: config.gid,
      });
    }
  },
  metadata: {
    definitions: definitions,
  },
};
