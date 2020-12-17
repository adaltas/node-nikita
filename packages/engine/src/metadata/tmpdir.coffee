
# {is_object, is_object_literal} = require 'mixme'
utils = require '../utils'
os = require 'os'
path = require 'path'
process = require 'process'
fs = require 'ssh2-fs'
exec = require 'ssh2-exec'

module.exports = ->
  module: '@nikitajs/engine/src/metadata/status'
  require: [
    '@nikitajs/engine/src/plugins/tools_find'
    '@nikitajs/engine/src/plugins/tools_path'
  ]
  hooks:
    'nikita:session:action':
      after: [
        '@nikitajs/engine/src/plugins/ssh'
        '@nikitajs/engine/src/metadata/uuid'
      ]
      handler: (action) ->
        throw utils.error 'METADATA_TMPDIR_INVALID', [
          'the "tmpdir" metadata value must be a boolean or a string,'
          "got #{JSON.stringify action.metadata.tmpdir}"
        ] unless typeof action.metadata.tmpdir in ['boolean', 'string', 'undefined']
        return unless action.metadata.tmpdir
        # SSH connection extraction
        ssh = if action.config.ssh is false
        then undefined
        else await action.tools.find (action) ->
          action.ssh
        # tmpdir = if ssh then '/tmp' else os.tmpdir()
        # Generate temporary location
        rootdir = if ssh then '/tmp' else os.tmpdir()
        tmpdir = switch typeof action.metadata.tmpdir
          when 'string'
            action.metadata.tmpdir
          when 'boolean'
            'nikita-'+action.metadata.uuid
        action.metadata.tmpdir = path.resolve rootdir, tmpdir
        # Temporary directory creation
        try
          await fs.mkdir ssh, action.metadata.tmpdir
          action.metadata.tmpdir_dispose = true
        catch err
          throw err unless err.code is 'EEXIST'
    'nikita:session:result':
      before: '@nikitajs/engine/src/plugins/ssh'
      handler: ({action}) ->
        # Value of tmpdir could still be true if there was an error in
        # one of the on_action hook, such as a invalid schema validation
        return unless typeof action.metadata.tmpdir is 'string'
        return unless action.metadata.tmpdir_dispose
        return if action.metadata.dirty
        # SSH connection extraction
        ssh = if action.config.ssh is false
        then undefined
        else await action.tools.find (action) ->
          # action.state['nikita:ssh:connection']
          action.ssh
        # Ensure the location is correct
        tmpdir = if ssh
        then '/tmp'
        else os.tmpdir()
        throw utils.error 'METADATA_TMPDIR_CORRUPTION', [
          'the "tmpdir" metadata value does not start as expected,'
          "got #{JSON.stringify action.metadata.tmpdir},"
          "expected to start with #{JSON.stringify tmpdir}"
        ] unless action.metadata.tmpdir.startsWith tmpdir
        # Temporary directory decommissioning
        await new Promise (resolve, reject) ->
          exec ssh, "rm -r '#{action.metadata.tmpdir}'", (err) ->
            if err then reject err else resolve()
