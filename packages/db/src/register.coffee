
# registration of `nikita.db` actions

registry = require '@nikitajs/engine/src/registry'

module.exports =
  db:
    database:
      '': '@nikitajs/db/src/database'
      exists: '@nikitajs/db/src/database/exists'
      remove: '@nikitajs/db/src/database/remove'
      wait: '@nikitajs/db/src/database/wait'
    query: '@nikitajs/db/src/query'
    schema:
      '': '@nikitajs/db/src/schema'
      exists: '@nikitajs/db/src/schema/exists'
      list: '@nikitajs/db/src/schema/list'
      remove: '@nikitajs/db/src/schema/remove'
    user:
      '': '@nikitajs/db/src/user'
      exists: '@nikitajs/db/src/user/exists'
      remove: '@nikitajs/db/src/user/remove'
(->
  await registry.register module.exports
)()
