
# Registration of `nikita.authconfig` actions

registry = require '@nikitajs/core/lib/registry'

module.exports =
  system:
    authconfig: '@nikitajs/system/src/authconfig'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
