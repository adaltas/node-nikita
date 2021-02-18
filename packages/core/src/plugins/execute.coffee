
session = require '../session'

module.exports =
  name: '@nikitajs/core/src/plugins/execute'
  require: [
    '@nikitajs/core/src/metadata/raw'
    '@nikitajs/core/src/metadata/disabled'
  ]
  hooks:
    'nikita:action':
      after: '@nikitajs/core/src/plugins/tools_find'
      handler: (action) ->
        return unless action.metadata.namespace.join('.') is 'execute'
        # bash = await find ({metadata: {bash}}) -> bash
        config.arch_chroot ?= await find ({metadata: {arch_chroot}}) -> arch_chroot
        config.dry ?= await find ({metadata: {dry}}) -> dry
        config.sudo ?= await find ({metadata: {sudo}}) -> sudo
        
