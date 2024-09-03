// Dependencies
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// ## Exports
export default {
  handler: async function ({ config }) {
    if (/.*@.*/.test(config.admin?.principal)) {
      // Normalize realm and principal for later usage of config
      if (config.admin.realm == null) {
        config.admin.realm = config.admin.principal.split("@")[1];
      }
    }
    if (!/^\S+@\S+$/.test(config.principal)) {
      config.principal = `${config.principal}@${config.admin.realm}`;
    }
    // Start execution
    const { $status: exists } = await this.krb5.execute({
      $shy: true,
      admin: config.admin,
      command: `getprinc ${config.principal}`,
      grep: new RegExp(`^.*${utils.regexp.escape(config.principal)}$`),
    });
    if (!exists) {
      await this.krb5.execute({
        $retry: 3,
        admin: config.admin,
        command:
          config.password ?
            `addprinc -pw ${config.password} ${config.principal}`
          : `addprinc -randkey ${config.principal}`,
      });
    }
    if (config.password && config.password_sync) {
      const cache_name = `/tmp/nikita_${Math.random()}`;
      await this.krb5.execute({
        $retry: 3,
        // Test the user password
        // On success, write the ticket to a temporary location before cleanup
        $unless_execute: `if ! echo ${config.password} | kinit '${config.principal}' -c '${cache_name}'; then exit 1; else kdestroy -c '${cache_name}'; fi`,
        admin: config.admin,
        command: `cpw -pw ${config.password} ${config.principal}`,
      });
    }
    if (!config.keytab) {
      return;
    }
    await this.krb5.ktadd({
      ...utils.object.filter(
        config,
        [],
        ["admin", "gid", "keytab", "mode", "principal", "realm", "uid"],
      ),
    });
  },
  metadata: {
    global: "krb5",
    definitions: definitions,
  },
};
