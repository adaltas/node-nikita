// Dependencies
const {is_object_literal, merge} = require('mixme');
const utils = require('../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    let $status = false;
    // Get DN
    if (!config.dn) {
      log({
        message: "Get DN of the database to modify",
        level: "DEBUG",
      });
      const { dn } = await this.ldap.tools.database(config, {
        suffix: config.suffix,
      });
      config.dn = dn;
      log({
        message: `Database DN is ${dn}`,
        level: "INFO",
      });
    }
    for (const acl of config.acls) {
      // Get ACLs
      log({
        message: "List all ACL of the directory",
        level: "DEBUG",
      });
      const { stdout } = await this.ldap.search(config, {
        attributes: ["olcAccess"],
        base: `${config.dn}`,
        filter: "(olcAccess=*)",
      });
      let current = null;
      let olcAccesses = [];
      for (const line of utils.string.lines(stdout)) {
        const match = /^olcAccess: (.*)$/.exec(line);
        if (match) {
          if (current != null) {
            olcAccesses.push(current); // Push previous rule
          }
          current = match[1];
        } else if (current != null) {
          if (/^ /.test(line)) {
            // Append to existing rule
            current += line.substr(1); // Close the rule
          } else {
            olcAccesses.push(current);
            current = null;
          }
        }
      }
      olcAccesses = utils.ldap.acl.parse(olcAccesses);
      // Diff
      let olcAccess = null;
      // Find match "to" property
      for (const access of olcAccesses) {
        if (acl.to === access.to) {
          olcAccess = merge(access);
          olcAccess.old = access;
          break;
        }
      }
      if (olcAccess) {
        // Modify rule or bypass perfect match
        let is_perfect_match = true;
        const not_found_acl = [];
        if (acl.by.length !== olcAccess.by.length) {
          is_perfect_match = false;
        } else {
          for (const i in acl.by) {
            const acl_by = acl.by[i];
            if (acl_by !== olcAccess.by[i]) {
              is_perfect_match = false;
            }
            let found = true;
            for (const access_by of olcAccess.by) {
              if (acl_by !== access_by) {
                found = false;
              }
            }
            if (!found) {
              not_found_acl.push(acl_by);
            }
          }
        }
        if (is_perfect_match) {
          log({
            message: "No modification to apply",
            level: "INFO",
          });
          continue;
        }
        if (not_found_acl.length) {
          log({
            message: "Modify access after undefined acl",
            level: "INFO",
          });
          for (const access_by of olcAccess.by) {
            not_found_acl.push(access_by);
          }
          olcAccess.by = not_found_acl;
        } else {
          log({
            message: "Modify access after reorder",
            level: "INFO",
          });
          if (typeof log === "function") {
            log("nikita `ldap.acl`: m");
          }
          olcAccess.by = acl.by;
        }
      } else {
        log({
          message: "Insert a new access",
          level: "INFO",
        });
        let index = olcAccesses.length;
        if (acl.first) {
          // not tested
          index = 0;
        }
        if (acl.place_before) {
          for (const i in olcAccesses) {
            const access = olcAccesses[i];
            if (access.to === acl.place_before) {
              index = i;
            }
          }
        } else if (acl.after) {
          for (const i in olcAccesses) {
            const access = olcAccesses[i];
            if (access.to === config.after) {
              index = i + 1;
            }
          }
        }
        olcAccess = {
          index: index,
          to: acl.to,
          by: acl.by,
          add: true,
        };
      }
      const old = olcAccess.old ? utils.ldap.acl.stringify(olcAccess.old) : undefined;
      olcAccess = utils.ldap.acl.stringify(olcAccess);
      const operations = {
        dn: config.dn,
        changetype: "modify",
        attributes: [],
      };
      if (old) {
        operations.attributes.push({
          type: "delete",
          name: "olcAccess",
        });
        operations.attributes.push({
          type: "add",
          name: "olcAccess",
          value: olcAccess,
        });
      } else {
        operations.attributes.push({
          type: "add",
          name: "olcAccess",
          value: olcAccess,
        });
      }
      await this.ldap.modify(config, {
        operations: operations,
      });
      $status = true;
    }
    return $status;
  },
  hooks: {
    on_action: function({config}) {
      if (is_object_literal(config.acls)) {
        return config.acls = [config.acls];
      }
    },
  },
  metadata: {
    global: "ldap",
    definitions: definitions,
  },
};
