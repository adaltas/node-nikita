
# `nikita.log.fs`

Write log to the host filesystem in a user provided format.

## Layout

By default, a file name "{{basename}}.log" will be created inside the base
directory defined by the option "basedir". 
The path looks like "{config.basedir}/{hostname}.log".

If the option "archive" is activated, a folder named after the current time is
created inside the base directory. A symbolic link named as "latest" will point
this is direction. The paths look like "{config.basedir}/{time}/{hostname}.log"
and "{config.basedir}/latest".

## Schema

    schema =
      type: 'object'
      properties:
        'archive':
          type: 'boolean'
          default: false
          description: """
          Save a copy of the previous logs inside a dedicated directory.
          """
        'basedir':
          type: 'string'
          default: './log'
          description: """
          Directory where to store logs relative to the process working
          directory. Default to the "log" directory. Note, when the `archive`
          option is activated, the log files will be stored accessible from
          "./log/latest".
          """
        'filename':
          type: 'string'
          default: '{{config.basename}}.log'
          description: """
          Name of the log file. The default behavior rely on the templated
          plugin to contextually render the filename.
          """
        'basename':
          type: 'string'
          default: 'localhost'
          description: """
          Default variable used by the filename rendering.
          """
        'serializer':
          type: 'object'
          description: """
          An object of key value pairs where keys are the event types and the
          value is a function which must be implemented to serialize the
          information.
          """
      required: ['serializer']

## Handler

    handler = ({config}) ->
      # Normalization
      config.basedir = path.resolve config.basedir
      # Archive config
      unless config.archive
        logdir = path.resolve config.basedir
      else
        latestdir = path.resolve config.basedir, 'latest'
        now = new Date()
        config.archive = "#{now.getFullYear()}".slice(-2) + "0#{now.getFullYear()}".slice(-2) + "0#{now.getDate()}".slice(-2) if config.archive is true
        logdir = path.resolve config.basedir, config.archive
      try
        await @fs.base.mkdir logdir
      catch err
        throw err unless err.code is 'NIKITA_FS_MKDIR_TARGET_EEXIST'
      # Events
      config.stream ?= fs.createWriteStream path.resolve logdir, config.filename
      await @call $: stream, config
      # Handle link to latest directory
      await @fs.base.symlink
        $if: latestdir
        source: logdir
        target: latestdir

## Exports

    module.exports =
      handler: handler
      ssh: false
      metadata:
        schema: schema

## Dependencies

    fs = require 'fs'
    path = require 'path'
    stream = require './stream'
