// Generated by CoffeeScript 2.5.1
// # `nikita.ldap.schema`

// Register a new ldap schema.

// ## Example

// ```js
// const {$status} = await nikita.ldap.schema({
//   uri: 'ldap://openldap.server/',
//   binddn: 'cn=admin,cn=config',
//   passwd: 'password',
//   name: 'kerberos',
//   schema: '/usr/share/doc/krb5-server-ldap-1.10.3/kerberos.schema'
// })
// console.info(`Schema created or modified: ${$status}`)
// ```

// ## Schema definitions
var definitions, handler;

definitions = {
  config: {
    type: 'object',
    properties: {
      'name': {
        type: 'string',
        description: `Common name of the schema.`
      },
      'schema': {
        type: 'string',
        description: `Path to the schema definition.`
      },
      // General LDAP connection information
      'binddn': {
        type: 'string',
        description: `Distinguished Name to bind to the LDAP directory.`
      },
      'passwd': {
        type: 'string',
        description: `Password for simple authentication.`
      },
      'uri': {
        type: 'string',
        description: `LDAP Uniform Resource Identifier(s), "ldapi:///" if true, default to
false in which case it will use your openldap client environment
configuration.`
      }
    }
  }
};

// ## Handler
handler = async function({
    config,
    metadata: {tmpdir},
    tools: {log}
  }) {
  var $status, binddn, conf, ldif, passwd, schema, uri;
  // Auth related config
  binddn = config.binddn ? `-D ${config.binddn}` : '';
  passwd = config.passwd ? `-w ${config.passwd}` : '';
  if (config.uri === true) {
    config.uri = 'ldapi:///';
  }
  uri = config.uri ? `-H ${config.uri}` : ''; // URI is obtained from local openldap conf unless provided
  if (!config.name) {
    // Schema related config
    throw Error("Missing name");
  }
  if (!config.schema) {
    throw Error("Missing schema");
  }
  config.schema = config.schema.trim();
  schema = `${tmpdir}/${config.name}.schema`;
  conf = `${tmpdir}/schema.conf`;
  ldif = `${tmpdir}/ldif`;
  ({$status} = (await this.execute({
    command: `ldapsearch -LLL ${binddn} ${passwd} ${uri} -b \"cn=schema,cn=config\" | grep -E cn=\\{[0-9]+\\}${config.name},cn=schema,cn=config`,
    code: 1,
    code_skipped: 0
  })));
  if (!$status) {
    return false;
  }
  await this.system.mkdir({
    target: ldif
  });
  log({
    message: 'Directory ldif created',
    level: 'DEBUG'
  });
  await this.system.copy({
    source: config.schema,
    target: schema
  });
  log({
    message: 'Schema copied',
    level: 'DEBUG'
  });
  await this.file({
    content: `include ${schema}`,
    target: conf
  });
  log({
    message: 'Configuration generated',
    level: 'DEBUG'
  });
  await this.execute({
    command: `slaptest -f ${conf} -F ${ldif}`
  });
  log({
    message: 'Configuration validated',
    level: 'DEBUG'
  });
  ({$status} = (await this.fs.move({
    source: `${ldif}/cn=config/cn=schema/cn={0}${config.name}.ldif`,
    target: `${ldif}/cn=config/cn=schema/cn=${config.name}.ldif`,
    force: true
  })));
  if (!$status) {
    throw Error('No generated schema');
  }
  log({
    message: 'Configuration renamed',
    level: 'DEBUG'
  });
  await this.file({
    target: `${ldif}/cn=config/cn=schema/cn=${config.name}.ldif`,
    write: [
      {
        match: /^dn: cn.*$/mg,
        replace: `dn: cn=${config.name},cn=schema,cn=config`
      },
      {
        match: /^cn: {\d+}(.*)$/mg,
        replace: 'cn: $1'
      },
      {
        match: /^structuralObjectClass.*/mg,
        replace: ''
      },
      {
        match: /^entryUUID.*/mg,
        replace: ''
      },
      {
        match: /^creatorsName.*/mg,
        replace: ''
      },
      {
        match: /^createTimestamp.*/mg,
        replace: ''
      },
      {
        match: /^entryCSN.*/mg,
        replace: ''
      },
      {
        match: /^modifiersName.*/mg,
        replace: ''
      },
      {
        match: /^modifyTimestamp.*/mg,
        replace: ''
      }
    ]
  });
  log({
    message: 'File ldif ready',
    level: 'DEBUG'
  });
  await this.execute({
    command: `ldapadd ${uri} ${binddn} ${passwd} -f ${ldif}/cn=config/cn=schema/cn=${config.name}.ldif`
  });
  return log({
    message: `Schema added: ${config.name}`,
    level: 'INFO'
  });
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    tmpdir: true,
    global: 'ldap',
    definitions: definitions
  }
};
