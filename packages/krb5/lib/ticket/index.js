
// Dependencies
import dedent from "dedent";
import utils from '@nikitajs/krb5/utils';
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    await this.execute({
      command: dedent`
        if ${utils.krb5.su(config, 'klist -s')}; then exit 3; fi
        ${utils.krb5.kinit(config)}
      `,
      code: [0, 3]
    });
    if (!((config.uid != null || config.gid != null) && config.keytab != null)) {
      return;
    }
    await this.fs.chown({
      uid: config.uid,
      gid: config.gid,
      target: config.keytab
    });
  },
  metadata: {
    // global: 'krb5',
    definitions: definitions
  }
};
