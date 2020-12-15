// Generated by CoffeeScript 2.5.1
// # `nikita.ldap.tools.database`

// Return the database associated with a suffix.

// ## Example

// ```js
// const {databases} = await nikita.ldap.tools.databases({
//   uri: 'ldap://localhost',
//   binddn: 'cn=admin,cn=config',
//   passwd: 'config'
// })
// // Value is similar to `[ '{-1}frontend', '{0}config', '{1}mdb' ]`
// databases.map( database => {
//   console.info(`Database: ${database}`)
// })
// ```

// ## Schema
var handler, schema, utils;

schema = {
  type: 'object',
  allOf: [
    {
      $ref: 'module://@nikitajs/ldap/src/search#/properties'
    },
    {
      properties: {
        'suffix': {
          type: 'string',
          description: `The suffix associated with the database.`
        }
      },
      required: ['suffix']
    }
  ]
};

// ## Handler
handler = async function({config}) {
  var _, database, dn, stdout;
  ({stdout} = (await this.ldap.search(config, {
    base: 'cn=config',
    filter: `(olcSuffix= ${config.suffix})`,
    attributes: ['dn']
  })));
  [_, dn] = stdout.split(':');
  dn = dn.trim();
  [_, database] = /^olcDatabase=(.*),/.exec(dn);
  return {
    dn: dn,
    database: database
  };
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    global: 'ldap',
    schema: schema
  }
};

// ## Dependencies
utils = require('../utils');
