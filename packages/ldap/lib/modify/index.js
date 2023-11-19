// Dependencies
import dedent from "dedent";
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    // Auth related config
    if (config.uri === true) {
      if (config.mesh == null) {
        config.mesh = 'EXTERNAL';
      }
      config.uri = 'ldapi:///';
    }
    // const uri = config.uri ? `-H ${config.uri}` : ''; // URI is obtained from local openldap conf unless provided
    // Add related config
    let ldif = '';
    const originals = [];
    for (const operation of config.operations) {
      if (!config.shortcut) {
        const {stdout} = await this.ldap.search(config, {
          base: operation.dn
        });
        originals.push(stdout);
      }
      // Generate ldif content
      ldif += '\n';
      ldif += `dn: ${operation.dn}\n`;
      ldif += "changetype: modify\n";
      for (const attribute of operation.attributes) {
        ldif += `${attribute.type}: ${attribute.name}\n`;
        if (attribute.value) {
          ldif += `${attribute.name}: ${attribute.value}\n`;
        }
        ldif += '-\n';
      }
    }
    await this.execute({
      command: [
        [
          "ldapmodify",
          config.continuous ? "-c" : undefined,
          config.mesh
            ? `-Y ${esa(config.mesh)}`
            : undefined,
          config.binddn
            ? `-D ${esa(config.binddn)}`
            : undefined,
          config.passwd
            ? `-w ${esa(config.passwd)}`
            : undefined,
          config.uri ? `-H ${esa(config.uri)}` : undefined,
        ].filter(Boolean).join(" "),
        dedent`
          <<-EOF
          ${ldif}
          EOF
        `,
      ].join(" "),
    });
    let status = false;
    for (const i in config.operations) {
      const operation = config.operations[i];
      if (!config.shortcut) {
        const {stdout} = await this.ldap.search(config, {
          base: operation.dn
        });
        if (stdout !== originals[i]) {
          status = true;
        }
      }
    }
    return status;
  },
  hooks: {
    on_action: function({config}) {
      if (!Array.isArray(config.operations)) {
        return config.operations = [config.operations];
      }
    }
  },
  metadata: {
    global: 'ldap'
  },
  definitions: definitions
};
