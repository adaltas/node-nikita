
// Dependencies
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    if (/.*@.*/.test(config.admin.principal)) {
      // Normalize realm and principal for later usage of config
      if (config.realm == null) {
        config.realm = config.admin.principal.split('@')[1];
      }
    }
    if (!/^\S+@\S+$/.test(config.principal)) {
      config.principal = `${config.principal}@${config.realm}`;
    }
    // Prepare commands
    const {$status} = await this.krb5.execute({
      $shy: true,
      admin: config.admin,
      command: `getprinc ${config.principal}`,
      grep: new RegExp(`^.*${utils.regexp.escape(config.principal)}$`)
    });
    await this.krb5.execute({
      $if: $status,
      admin: config.admin,
      command: `delprinc -force ${config.principal}`
    });
    await this.fs.remove({
      $if: config.keytab,
      target: config.keytab
    });
  },
  metadata: {
    global: 'krb5',
    definitions: definitions
  }
};
