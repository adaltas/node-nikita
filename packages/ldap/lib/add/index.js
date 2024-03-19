// Dependencies
import dedent from "dedent";
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import utils from "@nikitajs/ldap/utils"
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    // Auth related config
    if (config.uri === true) {
      if (config.mesh == null) {
        config.mesh = "EXTERNAL";
      }
      config.uri = "ldapi:///";
    }
    // Add related config
    let ldif = "";
    for (const entry of config.entry) {
      // Check if record already exists
      // exit code 32 is for "no such object"
      const { $status } = await this.ldap.search({
        ...utils.ldap.config_connection(config),
        base: entry.dn,
        code: [0, 32],
        scope: "base",
      });
      if ($status) {
        continue;
      }
      ldif += "\n";
      ldif += `dn: ${entry.dn}\n`;
      ldif += "changetype: add\n";
      const [_, k, v] = /^(.*?)=(.+?),.*$/.exec(entry.dn);
      ldif += `${k}: ${v}\n`;
      if (entry[k]) {
        if (entry[k] !== v) {
          throw Error(
            `Inconsistent value: ${entry[k]} is not ${v} for attribute ${k}`
          );
        }
        delete entry[k];
      }
      for (const k in entry) {
        let v = entry[k];
        if (k === "dn") {
          continue;
        }
        if (!Array.isArray(v)) {
          v = [v];
        }
        for (const vv of v) {
          ldif += `${k}: ${vv}\n`;
        }
      }
    }
    await this.execute({
      $if: ldif !== "",
      command: [
        [
          "ldapmodify",
          config.continuous ? "-c" : void 0,
          config.mesh
            ? `-Y ${esa(config.mesh)}`
            : void 0,
          config.binddn
            ? `-D ${esa(config.binddn)}`
            : void 0,
          config.passwd
            ? `-w ${esa(config.passwd)}`
            : void 0,
          config.uri ? `-H ${esa(config.uri)}` : void 0,
        ].join(" "),
        dedent`
          <<-EOF
          ${ldif}
          EOF
        `,
      ].join(" "),
    });
  },
  hooks: {
    on_action: function ({ config }) {
      if (!Array.isArray(config.entry)) {
        return (config.entry = [config.entry]);
      }
    },
  },
  metadata: {
    global: "ldap",
    definitions: definitions,
  },
};
