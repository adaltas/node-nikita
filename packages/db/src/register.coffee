
require('@nikitajs/core/lib/registry')
.register
  db:
    database:
      '': '@nikitajs/db/src/database'
      exists: '@nikitajs/db/src/database/exists'
      remove: '@nikitajs/db/src/database/remove'
      wait: '@nikitajs/db/src/database/wait'
    schema:
      '': '@nikitajs/db/src/schema'
      remove: '@nikitajs/db/src/schema/remove'
    user:
      '': '@nikitajs/db/src/user'
      exists: '@nikitajs/db/src/user/exists'
      remove: '@nikitajs/db/src/user/remove'
