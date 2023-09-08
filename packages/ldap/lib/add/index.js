// Dependencies
const dedent = require("dedent");
const utils = require("../utils");
const definitions = require("./schema.json");

// Action
module.exports = {
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
      const { $status, stdout } = await this.ldap.search(config, {
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
      [_, k, v] = /^(.*?)=(.+?),.*$/.exec(entry.dn);
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
            ? `-Y ${utils.string.escapeshellarg(config.mesh)}`
            : void 0,
          config.binddn
            ? `-D ${utils.string.escapeshellarg(config.binddn)}`
            : void 0,
          config.passwd
            ? `-w ${utils.string.escapeshellarg(config.passwd)}`
            : void 0,
          config.uri ? `-H ${utils.string.escapeshellarg(config.uri)}` : void 0,
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
