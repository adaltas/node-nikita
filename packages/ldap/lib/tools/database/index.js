// Dependencies
import utils from '@nikitajs/ldap/utils'
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const {stdout} = await this.ldap.search({
      ...utils.ldap.config_connection(config),
      base: config.base,
      filter: `(olcSuffix= ${config.suffix})`,
      attributes: ['dn']
    });
    const [, dn] = stdout.split(':').map(el => el.trim());
    const [, database] = /^olcDatabase=(.*),/.exec(dn);
    return {
      dn: dn,
      database: database
    };
  },
  metadata: {
    global: 'ldap',
    definitions: definitions
  }
};
