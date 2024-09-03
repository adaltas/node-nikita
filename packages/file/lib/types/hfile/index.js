// Dependencies
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
    let org_props = {};
    let fnl_props = {};
    let exists = true;
    // Read target properties
    log({
      message: `Read target properties from '${config.target}'`,
      level: "DEBUG",
    });
    try {
      // Populate org_props and, if merge, fnl_props
      const { data } = await this.fs.readFile({
        encoding: config.encoding,
        target: config.target,
      });
      org_props = utils.hfile.parse(data);
      if (config.merge) {
        fnl_props = {};
        for (const k in org_props) {
          fnl_props[k] = org_props[k];
        }
      }
    } catch (error) {
      if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
        throw error;
      }
      exists = false;
    }
    // Read source properties
    if (config.source && typeof config.source === "string") {
      log({
        message: `Read source properties from ${config.source}`,
        level: "DEBUG",
      });
      // Populate config.source
      const { data } = await this.fs.readFile({
        $ssh: config.local ? false : undefined,
        encoding: config.encoding,
        target: config.target,
      });
      config.source = utils.hfile.parse(data);
    }
    // Merge source properties
    if (config.source) {
      // Note, source properties overwrite current ones by source, not sure
      // if this is the safest approach
      log({
        message: "Merge source properties",
        level: "DEBUG",
      });
      for (const k in config.source) {
        let v = config.source[k];
        if (typeof v === "number") {
          v = `${v}`;
        }
        if (fnl_props[k] == null) {
          fnl_props[k] = v;
        }
      }
    }
    // Merge user properties
    log({
      message: "Merge user properties",
      level: "DEBUG",
    });
    for (const k in config.properties) {
      let v = config.properties[k];
      if (typeof v === "number") {
        v = `${v}`;
      }
      if (v == null) {
        delete fnl_props[k];
      } else if (Array.isArray(v)) {
        fnl_props[k] = v.join(",");
      } else if (typeof v !== "string") {
        throw Error(`Invalid value type '${typeof v}' for property '${k}'`);
      } else {
        fnl_props[k] = v;
      }
    }
    if (config.transform) {
      // Apply transformation
      fnl_props = config.transform(fnl_props);
    }
    // Final merge
    const keys = {};
    for (const key of Object.keys(org_props)) {
      keys[key] = true;
    }
    for (const key of Object.keys(fnl_props)) {
      if (keys[key] == null) {
        keys[key] = true;
      }
    }
    for (const key in Object.keys(keys)) {
      if (org_props[key] === fnl_props[key]) {
        continue;
      }
      log({
        message: `Property '${key}' was '${org_props[key]}' and is now '${fnl_props[key]}'`,
        level: "WARN",
      });
    }
    if (exists && Object.keys(keys).length === 0) {
      log({
        message: `No properties to write.`,
        level: "DEBUG",
      });
      return;
    }
    return await this.file({
      content: utils.hfile.stringify(fnl_props),
      target: config.target,
      source: void 0,
      backup: config.backup,
      backup_mode: config.backup_mode,
      eof: config.eof,
      encoding: config.encoding,
      uid: config.uid,
      gid: config.gid,
      mode: config.mode,
      local: config.local,
      unlink: config.unlink,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
