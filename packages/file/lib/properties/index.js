// Dependencies
import utils from "@nikitajs/file/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    // Trim
    let fnl_props = config.trim
      ? utils.object.trim(config.content)
      : config.content;
    log({
      message: `Merging \"${config.merge ? "true" : "false"}\"`,
      level: "DEBUG",
    });
    // Read Original
    const { exists } = await this.fs.base.exists({
      target: config.target,
    });
    const { properties } =
      exists &&
      (await this.file.properties.read({
        target: config.target,
        separator: config.separator,
        comment: config.comment,
        trim: config.trim,
      }));
    const org_props = properties || {};
    // Diff
    await this.call(function () {
      let status = false;
      const keys = {};
      for (const k in Object.keys(org_props)) {
        keys[k] = true;
      }
      for (const k of Object.keys(fnl_props)) {
        keys[k] = true;
      }
      for (const key of Object.keys(keys)) {
        if (`${org_props[key]}` !== `${fnl_props[key]}`) {
          log({
            message: `Property '${key}' was '${org_props[key]}' and is now '${fnl_props[key]}'`,
            level: "WARN",
          });
          if (fnl_props[key] != null) {
            status = true;
          }
        }
      }
      return status;
    });
    // Merge
    if (config.merge) {
      for (const k in fnl_props) {
        const v = fnl_props[k];
        org_props[k] = fnl_props[k];
      }
      fnl_props = org_props;
    }
    // Write data
    const keys = config.sort
      ? Object.keys(fnl_props).sort()
      : Object.keys(fnl_props);
    const data = keys.map((key) =>
      fnl_props[key] != null
        ? `${key}${config.separator}${fnl_props[key]}`
        : `${key}`
    );
    await this.file({
      $shy: true,
      target: `${config.target}`,
      content: data.join("\n"),
      backup: config.backup,
      eof: true,
    });
    if (config.uid || config.gid) {
      await this.system.chown({
        target: config.target,
        uid: config.uid,
        gid: config.gid,
      });
    }
    if (config.mode) {
      await this.system.chmod({
        target: config.target,
        mode: config.mode,
      });
    }
  },
  metadata: {
    definitions: definitions,
  },
};
