
// todo: remove coffee and replace src by lib
require('coffeescript/register')

require('@nikitajs/db/src/register')
require('@nikitajs/docker/src/register')
require('@nikitajs/file/src/register')
require('@nikitajs/ipa/src/register')
require('@nikitajs/java/src/register')
require('@nikitajs/krb5/src/register')
require('@nikitajs/ldap/src/register')
require('@nikitajs/lxd/src/register')
require('@nikitajs/network/src/register')
// require('@nikitajs/service/src/register')
require('@nikitajs/tools/src/register')
module.exports = require('@nikitajs/engine')
