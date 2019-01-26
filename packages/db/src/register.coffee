
require('@nikita/core/lib/registry')
.register
  db:
    database:
      '': '@nikita/db/src/database'
      exists: '@nikita/db/src/database/exists'
      remove: '@nikita/db/src/database/remove'
      wait: '@nikita/db/src/database/wait'
    schema:
      '': '@nikita/db/src/schema'
      remove: '@nikita/db/src/schema/remove'
    user:
      '': '@nikita/db/src/user'
      exists: '@nikita/db/src/user/exists'
      remove: '@nikita/db/src/user/remove'
