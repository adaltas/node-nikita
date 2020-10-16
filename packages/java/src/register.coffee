
# registration of `nikita.java` actions

require '@nikitajs/file/src/register'
registry = require '@nikitajs/engine/src/registry'

module.exports =
  java:
    keystore_add: '@nikitajs/java/src/keystore_add'
    keystore_remove: '@nikitajs/java/src/keystore_remove'
(->
  await registry.register module.exports
)()
