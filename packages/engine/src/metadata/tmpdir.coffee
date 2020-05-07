
# {is_object, is_object_literal} = require 'mixme'
error = require '../utils/error'
os = require 'os'
path = require 'path'
process = require 'process'
fs = require 'ssh2-fs'
exec = require 'ssh2-exec'

module.exports = ->
  module: '@nikitajs/engine/src/metadata/status'
  require: [
    '@nikitajs/engine/src/plugins/operation_find'
    '@nikitajs/engine/src/plugins/operation_path'
  ]
  hooks:
    'nikita:registry:normalize': (action) ->
      action.metadata ?= {}
      if action.hasOwnProperty 'tmpdir'
        action.metadata.tmpdir = action.tmpdir
        delete action.tmpdir
      if action.hasOwnProperty 'dirty'
        action.metadata.dirty = action.dirty
        delete action.dirty
    'nikita:session:normalize': (action) ->
      if action.hasOwnProperty 'tmpdir'
        action.metadata.tmpdir = action.tmpdir
        delete action.tmpdir
      if action.hasOwnProperty 'dirty'
        action.metadata.dirty = action.dirty
        delete action.dirty
    'nikita:session:action':
      after: '@nikitajs/engine/src/metadata/ssh'
      handler: (action, handler) ->
        return handler unless action.metadata.tmpdir
        # SSH connection extraction
        ssh = if action.config.ssh is false
        then undefined
        else await action.operations.find (action) ->
          # action.state['nikita:ssh:connection']
          action.ssh
        tmpdir = if ssh then '/tmp' else os.tmpdir()
        # Generate temporary location
        rootdir = if ssh then '/tmp' else os.tmpdir()
        now = new Date()
        tmpdir = switch typeof action.metadata.tmpdir
          when 'string'
            action.metadata.tmpdir
          when 'boolean'
            [
              'nikita_'
              "#{now.getFullYear()}".substr 2
              "#{now.getMonth()}".padStart 2, '0'
              "#{now.getDate()}".padStart 2, '0'
              '_'
              process.pid
              '_'
              (Math.random() * 0x100000000 + 1).toString(36)
            ].join ''
        action.metadata.tmpdir = path.resolve rootdir, tmpdir
        # Temporary directory creation
        try
          await fs.mkdir ssh, action.metadata.tmpdir
        catch err
          throw err unless err.code is 'EEXIST'
        handler
    'nikita:session:result':
      before: '@nikitajs/engine/src/metadata/ssh'
      handler: ({action}) ->
        # Value of tmpdir could still be true if there was an error in
        # one of the on_action hook, such as a invalid schema validation
        return unless typeof action.metadata.tmpdir is 'string'
        return if action.metadata.dirty
        # SSH connection extraction
        ssh = if action.config.ssh is false
        then undefined
        else await action.operations.find (action) ->
          # action.state['nikita:ssh:connection']
          action.ssh
        # Ensure the location is correct
        tmpdir = if ssh
        then '/tmp'
        else os.tmpdir()
        throw error 'METADATA_TMPDIR_CORRUPTION', [
          'the "tmpdir" metadata value does not start as expected,'
          "got #{JSON.stringify action.metadata.tmpdir},"
          "expected to start with #{JSON.stringify tmpdir}"
        ] unless action.metadata.tmpdir.startsWith tmpdir
        # Temporary directory decommissioning
        await new Promise (resolve, reject) ->
          exec ssh, "rm -r '#{action.metadata.tmpdir}'", (err) ->
            if err then reject err else resolve()
