
const utils = require('@nikitajs/core/lib/utils');
const ldap = require('./ldap');

module.exports = {
  ...utils,
  ldap: ldap
};
