// Dependencies
const {merge} = require('mixme');
const utils = require('../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    if (!Array.isArray(config.user)) {
      // User related config
      // Note, very weird, if we don't merge, the user array is traversable but
      // the keys map to undefined values.
      config.user = [merge(config.user)];
    }
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
        log({
          message: "User added",
          level: "WARN",
          module: "nikita/ldap/user",
        });
      } else if (updated) {
        log({
          message: "User updated",
          level: "WARN",
          module: "nikita/ldap/user",
        });
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
              ? `-Y ${utils.string.escapeshellarg(config.mesh)}`
              : void 0,
            config.binddn
              ? `-D ${utils.string.escapeshellarg(config.binddn)}`
              : void 0,
            config.passwd
              ? `-w ${utils.string.escapeshellarg(config.passwd)}`
              : void 0,
            config.uri
              ? `-H ${utils.string.escapeshellarg(config.uri)}`
              : void 0,
            `-s ${user.userPassword}`,
            `${utils.string.escapeshellarg(user.dn)}`,
          ].join(" "),
        });
        log({
          message: "Password modified",
          level: "WARN",
        });
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
