
{is_object_literal} = require 'mixme'
{mutate} = require 'mixme'
utils = require '../../utils'
os = require 'os'
process = require 'process'
fs = require 'ssh2-fs'
exec = require 'ssh2-exec/promise'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/tmpdir'
  require: [
    '@nikitajs/core/src/plugins/tools/find'
    '@nikitajs/core/src/plugins/tools/path'
  ]
  hooks:
    # 'nikita:schema': ({schema}) ->
    #   mutate schema.definitions.metadata.properties,
    #     tmpdir:
    #       oneOf: [
    #         type: ['boolean', 'string']
    #       ,
    #         typeof: 'function'
    #       ]
    #       description: '''
    #       Creates a temporary directory for the duration of the action
    #       execution.
    #       '''
    'nikita:action':
      before: [
        '@nikitajs/core/src/plugins/templated'
      ]
      after: [
        '@nikitajs/core/src/plugins/execute'
        '@nikitajs/core/src/plugins/ssh'
        '@nikitajs/core/src/plugins/tools/path'
        '@nikitajs/core/src/plugins/metadata/uuid'
        # Probably related to pb above
        # '@nikitajs/core/src/plugins/metadata/schema'
      ]
      handler: (action) ->
        {config, metadata, tools} = action
        throw utils.error 'METADATA_TMPDIR_INVALID', [
          'the "tmpdir" metadata value must be a boolean, a function, an object or a string,'
          "got #{JSON.stringify metadata.tmpdir}"
        ] unless (
          (typeof metadata.tmpdir in ['boolean', 'function', 'string', 'undefined']) or
          (is_object_literal metadata.tmpdir)
        )
        # tmpdir is explicit, it must be defined to be available as a metadata
        # wether we switch with sudo or ssh, if not defined, there is nothing to do
        return unless metadata.tmpdir
        # SSH connection extraction
        ssh = if config.ssh is false
        then undefined
        else await tools.find (action) -> action.ssh
        # Sudo extraction
        sudo = await tools.find ({metadata}) -> metadata.sudo
        # Generate temporary location
        os_tmpdir = if ssh then '/tmp' else os.tmpdir()
        ssh_hash = if ssh then utils.ssh.hash ssh else null
        tmp_hash = utils.string.hash JSON.stringify {
          ssh_hash: ssh_hash
          sudo: sudo
          uuid: metadata.uuid
        }
        tmpdir_info = switch typeof metadata.tmpdir
          when 'string'
            target: metadata.tmpdir
          when 'boolean'
            target: 'nikita-'+tmp_hash
            hash: tmp_hash
          when 'function'
            await metadata.tmpdir.call null,
              action: action
              os_tmpdir: os_tmpdir
              tmpdir: 'nikita-'+tmp_hash
          when 'object'
            # metadata.tmpdir.target ?= 'nikita-'+tmp_hash
            metadata.tmpdir
          else
            undefined
        # Current context
        tmpdir_info.uuid ?= metadata.uuid
        tmpdir_info.ssh_hash ?= ssh_hash
        tmpdir_info.sudo ?= sudo
        tmpdir_info.mode ?= 0o0744
        tmpdir_info.hash ?= utils.string.hash JSON.stringify tmpdir_info
        tmpdir_info.target ?= 'nikita-'+tmpdir_info.hash
        tmpdir_info.target = tools.path.resolve os_tmpdir, tmpdir_info.target
        
        metadata.tmpdir = tmpdir_info.target
        exists = action.parent and await tools.find action.parent, ({metadata}) ->
          return unless metadata.tmpdir
          if tmpdir_info.hash is metadata.tmpdir_info?.hash
            true
        return if exists
        try
          await fs.mkdir ssh, metadata.tmpdir, tmpdir_info.mode
          await exec ssh, "sudo chown root:root '#{metadata.tmpdir}'" if tmpdir_info.sudo
          metadata.tmpdir_info = tmpdir_info
        catch err
          throw err unless err.code is 'EEXIST'
    'nikita:result':
      before: '@nikitajs/core/src/plugins/ssh'
      handler: ({action}) ->
        {config, metadata, tools} = action
        # Value of tmpdir could still be true if there was an error in
        # one of the on_action hook, such as a invalid schema validation
        return unless typeof metadata.tmpdir is 'string'
        return unless metadata.tmpdir_info
        return if await tools.find ({metadata}) -> metadata.dirty
        # SSH connection extraction
        ssh = if config.ssh is false
        then undefined
        else await tools.find action, (action) -> action.ssh
        # Temporary directory decommissioning
        await exec ssh, [
          'sudo' if metadata.tmpdir_info.sudo
          "rm -r '#{metadata.tmpdir}'"
        ].join ' '
