// Dependencies
import { is_object_literal, merge } from "mixme";
import utils from "@nikitajs/ldap/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    let $status = false;
    // Get DN
    if (!config.dn) {
      log("DEBUG", "Get DN of the database to modify");
      config.dn = await this.ldap.tools
        .database({
          ...utils.ldap.config_connection(config),
          suffix: config.suffix,
        })
        .then(({ dn }) => dn);
      log("INFO", `Database DN is ${config.dn}`);
    }
    for (const acl of config.acls) {
      // Get ACLs
      log("DEBUG", "List all ACL of the directory");
      const { stdout } = await this.ldap.search({
        ...utils.ldap.config_connection(config),
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
            current += line.slice(1); // Close the rule
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
          log("INFO", "No modification to apply");
          continue;
        }
        if (not_found_acl.length) {
          log("INFO", "Modify access after undefined acl");
          for (const access_by of olcAccess.by) {
            not_found_acl.push(access_by);
          }
          olcAccess.by = not_found_acl;
        } else {
          log("INFO", "Modify access after reorder");
          olcAccess.by = acl.by;
        }
      } else {
        log("INFO", "Insert a new access");
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
      const old =
        olcAccess.old ? utils.ldap.acl.stringify(olcAccess.old) : undefined;
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
      await this.ldap.modify({
        ...utils.ldap.config_connection(config),
        operations: operations,
      });
      $status = true;
    }
    return $status;
  },
  hooks: {
    on_action: function ({ config }) {
      if (is_object_literal(config.acls)) {
        return (config.acls = [config.acls]);
      }
    },
  },
  metadata: {
    global: "ldap",
    definitions: definitions,
  },
};
