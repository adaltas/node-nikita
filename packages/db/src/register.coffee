
# Registration of `nikita.db` actions

## Dependency

    {register} = require '@nikitajs/core/lib/registry'

## Action registration

    register
      db:
        database:
          '': '@nikitajs/db/src/database'
          exists: '@nikitajs/db/src/database/exists'
          remove: '@nikitajs/db/src/database/remove'
          wait: '@nikitajs/db/src/database/wait'
        query: '@nikitajs/db/src/query'
        schema:
          '': '@nikitajs/db/src/schema'
          remove: '@nikitajs/db/src/schema/remove'
        user:
          '': '@nikitajs/db/src/user'
          exists: '@nikitajs/db/src/user/exists'
          remove: '@nikitajs/db/src/user/remove'
