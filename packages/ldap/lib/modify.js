// Generated by CoffeeScript 2.5.1
// # `nikita.ldap.modify`

// Insert, modify or remove entries inside an OpenLDAP server.   

// ## Example

// ```js
// {status} = await require('nikita').ldap.modify({
//   uri: 'ldap://openldap.server/',
//   binddn: 'cn=admin,dc=company,dc=com',
//   passwd: 'secret',
//   operations: [{
//     'dn': 'cn=my_group,ou=groups,dc=company,dc=com'
//     'changetype': 'modify',
//     'values': [{
//       'replace': 'gidNumber',
//       'gidNumber': 9602,
//     }]
//   }]
// })
// console.log(`Entry modified: ${status}`)
// ```

// ## Hooks
var compare, handler, on_action, schema, utils;

on_action = function({config}) {
  if (!Array.isArray(config.operations)) {
    return config.operations = [config.operations];
  }
};

// ## Schema
schema = {
  type: 'object',
  properties: {
    'operations': {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          'changetype': {
            type: 'string',
            enum: ['add', 'modify', 'remove'],
            description: `Valid operation type`
          },
          'attributes': {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                'type': {
                  type: 'string',
                  enum: ['add', 'delete', 'replace'],
                  description: `Operation type.`
                },
                'name': {
                  type: 'string',
                  description: `Attribute name.`
                },
                'value': {
                  type: 'string',
                  description: `Attribute value.`
                }
              },
              required: ['type', 'name']
            },
            description: `List of attribute operations`
          }
        }
      },
      description: `Object to be inserted, modified or removed.`
    },
    exclude: {
      type: 'array',
      items: {
        type: 'string'
      },
      default: [],
      description: `List of attribute to not compare, eg \`userPassword\`.`
    },
    // General LDAP connection information
    'binddn': {
      type: 'string',
      description: `Distinguished Name to bind to the LDAP directory.`
    },
    'mesh': {
      type: 'string',
      description: `Specify the SASL mechanism to be used for authentication. If it's not
specified, the program will choose the best  mechanism  the  server
knows.`
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
  },
  required: ['operations']
};

// ## Handler
handler = async function({config}) {
  var attribute, i, j, k, l, ldif, len, len1, len2, operation, originals, ref, ref1, ref2, result, status, stdout, uri;
  // Auth related config
  // binddn = if config.binddn then "-D #{config.binddn}" else ''
  // passwd = if config.passwd then "-w #{config.passwd}" else ''
  // config.uri = 'ldapi:///' if config.uri is true
  if (config.uri === true) {
    if (config.mesh == null) {
      config.mesh = 'EXTERNAL';
    }
    config.uri = 'ldapi:///';
  }
  uri = config.uri ? `-H ${config.uri}` : ''; // URI is obtained from local openldap conf unless provided
  // Add related config
  ldif = '';
  originals = [];
  ref = config.operations;
  for (j = 0, len = ref.length; j < len; j++) {
    operation = ref[j];
    if (!config.shortcut) {
      ({stdout} = (await this.ldap.search(config, {
        base: operation.dn
      })));
      originals.push(stdout);
    }
    // Generate ldif content
    ldif += '\n';
    ldif += `dn: ${operation.dn}\n`;
    ldif += "changetype: modify\n";
    ref1 = operation.attributes;
    for (k = 0, len1 = ref1.length; k < len1; k++) {
      attribute = ref1[k];
      ldif += `${attribute.type}: ${attribute.name}\n`;
      if (attribute.value) {
        ldif += `${attribute.name}: ${attribute.value}\n`;
      }
      ldif += '-\n';
    }
  }
  result = (await this.execute({
    cmd: [
      ['ldapmodify',
      config.continuous ? '-c' : void 0,
      config.mesh ? `-Y ${utils.string.escapeshellarg(config.mesh)}` : void 0,
      config.binddn ? `-D ${utils.string.escapeshellarg(config.binddn)}` : void 0,
      config.passwd ? `-w ${utils.string.escapeshellarg(config.passwd)}` : void 0,
      config.uri ? `-H ${utils.string.escapeshellarg(config.uri)}` : void 0].join(' '),
      `<<-EOF
${ldif}
EOF`
    ].join(' ')
  }));
  status = false;
  ref2 = config.operations;
  for (i = l = 0, len2 = ref2.length; l < len2; i = ++l) {
    operation = ref2[i];
    if (!config.shortcut) {
      ({stdout} = (await this.ldap.search(config, {
        base: operation.dn
      })));
      if (stdout !== originals[i]) {
        status = true;
      }
    }
  }
  return status;
};

// ## Exports
module.exports = {
  handler: handler,
  hooks: {
    on_action: on_action
  },
  metadata: {
    global: 'ldap'
  },
  schema: schema
};

// ## Dependencies
({compare} = require('mixme'));

utils = require('./utils');
