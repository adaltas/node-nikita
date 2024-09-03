// Dependencies
import fs from "node:fs";
import path from "node:path";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // Normalization
    let logdir = path.dirname(config.filename);
    if (config.basedir) {
      logdir = path.resolve(config.basedir, logdir);
    }
    // Archive config
    let latestdir;
    if (config.archive) {
      latestdir = path.resolve(logdir, "latest");
      const now = new Date();
      if (config.archive === true) {
        config.archive =
          `${now.getFullYear()}`.slice(-2) +
          `0${now.getFullYear()}`.slice(-2) +
          `0${now.getDate()}`.slice(-2);
      }
      logdir = path.resolve(config.basedir, config.archive);
    }
    try {
      await fs.promises.mkdir(logdir, { recursive: true });
    } catch (error) {
      if (error.code !== "EEXIST") {
        throw error;
      }
    }
    // Events
    // if (config.stream == null) {
    //   config.stream = fs.createWriteStream(path.resolve(logdir, path.basename(config.filename)));
    // }
    await this.log.stream({
      serializer: config.serializer,
      stream:
        config.stream ??
        fs.createWriteStream(
          path.resolve(logdir, path.basename(config.filename)),
        ),
    });
    // Handle link to latest directory
    await this.fs.symlink({
      $if: latestdir,
      $ssh: false,
      source: logdir,
      target: latestdir,
    });
  },
  hooks: {
    on_action: {
      before: ["@nikitajs/core/plugins/metadata/schema"],
      after: ["@nikitajs/core/plugins/ssh"],
      handler: function ({ config, ssh }) {
        // With ssh, filename contain the host or ip address
        config.filename ??= `${ssh?.config?.host || "local"}.log`;
        // Log is always local
        // config.ssh = false;
      },
    },
  },
  metadata: {
    definitions: definitions,
  },
};
