
# Utils

    # Extends Nikita utils
    utils = require('@nikitajs/engine/lib/utils')
    ldap = require './ldap'

    module.exports = {
      ...utils
      ldap: ldap
    }
