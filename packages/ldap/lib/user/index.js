// Dependencies
import {merge} from 'mixme';
import { escapeshellarg as esa } from "@nikitajs/utils/string";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    let modified = false;
    for (const user of config.user) {
      // Add the user
      const entry = {};
      for (const key in user) {
        if (key === "userPassword" && !/^\{SASL\}/.test(user.userPassword)) {
          continue;
        }
        entry[key] = user[key];
      }
      const { updated, added } = await this.ldap.add({
        entry: entry,
        uri: config.uri,
        binddn: config.binddn,
        passwd: config.passwd,
      });
      if (added) {
        log("WARN", "User added.");
      } else if (updated) {
        log("WARN", "User updated.");
      }
      if (updated || added) {
        modified = true;
      }
      // Check password is user is not new and his password is not of type SASL
      let new_password = false;
      if (!added && user.userPassword && !/^\{SASL\}/.test(user.userPassword)) {
        const { $status: loggedin } = await this.ldap.search({
          // See https://onemoretech.wordpress.com/2011/09/22/verifying-ldap-passwords/
          binddn: user.dn,
          passwd: user.userPassword,
          uri: config.uri,
          base: "",
          scope: "base",
          filter: "objectclass=*",
          code: [0, 49],
        });
        if (!loggedin) {
          new_password = true;
        }
      }
      if (added || (new_password && !/^\{SASL\}/.test(user.userPassword))) {
        await this.execute({
          command: [
            "ldappasswd",
            config.mesh
              ? `-Y ${esa(config.mesh)}`
              : void 0,
            config.binddn
              ? `-D ${esa(config.binddn)}`
              : void 0,
            config.passwd
              ? `-w ${esa(config.passwd)}`
              : void 0,
            config.uri
              ? `-H ${esa(config.uri)}`
              : void 0,
            `-s ${user.userPassword}`,
            `${esa(user.dn)}`,
          ].join(" "),
        });
        log("WARN", "Password modified");
        modified = true;
      }
    }
    return {
      $status: modified,
    };
  },
  metadata: {
    global: "ldap",
    definitions: definitions,
  },
};
