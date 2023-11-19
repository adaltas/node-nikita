// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    // Auth related config
    const binddn = config.binddn ? `-D ${config.binddn}` : '';
    const passwd = config.passwd ? `-w ${config.passwd}` : '';
    if (config.uri === true) {
      config.uri = 'ldapi:///';
    }
    const uri = config.uri ? `-H ${config.uri}` : ''; // URI is obtained from local openldap conf unless provided
    if (!Array.isArray(config.dn)) {
      // Add related config
      config.dn = [config.dn];
    }
    const dn = config.dn.map((dn) => `'${dn}'` ).join(' ');
    await this.execute({
      // Check that the entry exists
      $if_execute: `ldapsearch ${binddn} ${passwd} ${uri} -b ${dn} -s base`,
      command: `ldapdelete ${binddn} ${passwd} ${uri} ${dn}`
    });
  },
  metadata: {
    global: 'ldap',
    definitions: definitions
  }
};
