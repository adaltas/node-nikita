
# {is_object, is_object_literal} = require 'mixme'
error = require '../utils/error'
os = require 'os'
process = require 'process'
fs = require 'ssh2-fs'
exec = require 'ssh2-exec'

module.exports = ->
  module: '@nikitajs/engine/src/metadata/status'
  require: '@nikitajs/engine/src/plugins/operation_find'
  cascade: false
  hooks:
    'nikita:registry:normalize': (action) ->
      action.metadata ?= {}
      if action.hasOwnProperty 'tmpdir'
        action.metadata.tmpdir = action.tmpdir
        delete action.tmpdir
    'nikita:session:normalize': (action) ->
      if action.hasOwnProperty 'tmpdir'
        action.metadata.tmpdir = action.tmpdir
        delete action.tmpdir
    'nikita:session:action': (action, handler) ->
      return handler unless action.metadata.tmpdir
      # SSH connection extraction
      ssh = if action.config.ssh is false
      then undefined
      else await action.operations.find (action) ->
        action.state['nikita:ssh:connection']
      tmpdir = if ssh then '/tmp' else os.tmpdir()
      # Generate temporary location
      now = new Date()
      action.metadata.tmpdir = [
        tmpdir
        '/nikita_'
        "#{now.getFullYear()}".substr 2
        now.getMonth()
        now.getDate()
        '_'
        process.pid
        '_'
        (Math.random() * 0x100000000 + 1).toString(36)
      ].join ''
      # Temporary directory creation
      await fs.mkdir ssh, action.metadata.tmpdir
      handler
    'nikita:session:result': ({action}, handler) ->
      return handler unless action.metadata.tmpdir
      # SSH connection extraction
      ssh = if action.config.ssh is false
      then undefined
      else await action.operations.find (action) ->
        action.state['nikita:ssh:connection']
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
      handler
