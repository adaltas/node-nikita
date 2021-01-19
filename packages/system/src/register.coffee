
# Registration of `nikita.system` actions

require '@nikitajs/file/lib/register'
registry = require '@nikitajs/engine/lib/registry'

module.exports =
  system:
    limits: '@nikitajs/system/src/limits'
    mod: '@nikitajs/system/src/mod'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
