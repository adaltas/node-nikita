// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    const {stdout} = await this.ldap.search(config, {
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
