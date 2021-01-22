
# Registration of `nikita.system` actions

require '@nikitajs/file/lib/register'
registry = require '@nikitajs/engine/lib/registry'

module.exports =
  system:
    authconfig: '@nikitajs/system/src/authconfig'
    cgroups: '@nikitajs/system/src/cgroups'
    info:
      disks: '@nikitajs/system/src/info/disks'
      os: '@nikitajs/system/src/info/os'
    limits: '@nikitajs/system/src/limits'
    mod: '@nikitajs/system/src/mod'
    running: '@nikitajs/system/src/running'
    tmpfs: '@nikitajs/system/src/tmpfs'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
