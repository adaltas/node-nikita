// Dependencies
import utils from "@nikitajs/ldap/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    const indexes = {};
    const add = {};
    const modify = {};
    if (!config.dn) {
      log("DEBUG", "Get DN of the database to modify");
      ({ dn: config.dn } = await this.ldap.tools.database(config, {
        suffix: config.suffix,
      }));
      log("INFO", `Discovered database DN is ${config.dn}`);
    }
    // List all indexes of the directory
    log("DEBUG", "List all indexes of the directory");
    const { stdout } = await this.ldap.search(config, {
      attributes: ["olcDbIndex"],
      base: `${config.dn}`,
      filter: "(olcDbIndex=*)",
    });
    for (const line of utils.string.lines(stdout)) {
      let match; if (!(match = /^olcDbIndex:\s+(.*)\s+(.*)/.exec(line))) {
        continue;
      }
      const [, attrlist, indices] = match;
      indexes[attrlist] = indices;
    }
    // Check for changes
    for (const k in config.indexes) {
      const v = config.indexes[k];
      if (indexes[k] == null) {
        add[k] = v;
      } else if (v !== indexes[k]) {
        modify[k] = [v, indexes[k]];
      }
    }
    // Apply the modifications
    if (Object.keys(add).length != null || Object.keys(modify).length != null) {
      const operations = {
        dn: config.dn,
        changetype: "modify",
        attributes: [],
      };
      for (const k in add) {
        const v = add[k];
        operations.attributes.push({
          type: "add",
          name: "olcDbIndex",
          value: `${k} ${v}`,
        });
      }
      for (const k in modify) {
        const v = modify[k];
        operations.attributes.push({
          type: "delete",
          name: "olcDbIndex",
          value: `${k} ${v[1]}`,
        });
        operations.attributes.push({
          type: "add",
          name: "olcDbIndex",
          value: `${k} ${v[0]}`,
        });
      }
      await this.ldap.modify(config, {
        operations: operations,
      });
    }
  },
  metadata: {
    global: "ldap",
    definitions: definitions,
  },
};
