
# `nikita.tools.backup`

Backup a file, a directory or the output of a command.

## Callback parameters

* `err` (Error)   
  Error object if any.   
* `status`  (boolean)   
  Value is "true" if backup was created.   
* `base_dir` (string)   
* `name` (string)   
* `filename` (string)   
* `target` (string)   

## Example

Backup a directory:

```js
const {status} = await nikita.tools.backup({
  name: 'my_backup',
  source: '/etc',
  target: '/tmp/backup',
  algorithm: 'gzip',  # Value are "gzip", "bzip2", "xz" or "none"
  extension: 'tgz'
  // retention: {
  //  count: 3
  //  date: '2015-01-01-00:00:00'
  //  age: month: 2
  // }
})
console.info(`File was backed up: ${status}`)
```

## Schema

    schema =
      type: 'object'
      properties:
        name:
          type: 'string'
          description: """
          Backup file name, required.
          """
        command:
          type: 'string'
          description: """
          Command from which to pipe the ouptut or generating a file if the
          "target" option is defined.
          """
        format:
          type: 'string'
          description: """
          Format used to name the backup directory, used by [Moment.js], default
          to "ISO-8601".
          """
        locale:
          type: 'string'
          description: """
          Locale used to name the backup directory, used by [Moment.js], default
          to  UTC.
          """
        compress:
          oneOf: [
            $ref: 'module://@nikitajs/tools/src/compress#/properties/format'
          ,
            type: 'boolean'
          ]
          description: """
          One of "tgz", "tar", "xz", "bz2" or "zip", default to "tgz" if true or
          a directory otherwise no compression.
          """
        source:
          oneOf: [
            type: 'boolean'
          ,
            type: 'string'
          ]
          description: """
          Path to a file or a directory to backup.
          """
        target:
          type: 'string'
          description: """
          Directory storing the backup, required.
          """
        timezone:
          type: 'string'
          default: 'UTC'
          description: """
          The time zone to use. The only value implementations must recognize is
          "UTC"; the default is the runtime's default time zone. Implementations
          may also recognize the time zone names of the [IANA time zone
          database](https://www.iana.org/time-zones), such as "Asia/Shanghai",
          "Asia/Kolkata", "America/New_York".
          """
      required: ['name', 'target']

# Handler

    handler = ({config, tools: {log, path}}) ->
      filename = dayjs()
      if config.local
        filename = filename.locale config.locale
      if config.timezone
        filename = filename.tz config.timezone
      else
        filename = filename.utc()
      if config.format
        filename = filename.format config.format
      else
        filename = filename.toISOString()
        
      compress = if config.compress is true then 'tgz' else config.compress
      filename = "#{filename}.#{compress}" if compress
      
      target = "#{config.target}/#{config.name}/#{filename}"
      log message: "Source is #{JSON.stringify config.source}", level: 'INFO', module: 'nikita/lib/tools/backup'
      log message: "Target is #{JSON.stringify target}", level: 'INFO', module: 'nikita/lib/tools/backup'
      @fs.mkdir "#{path.dirname target}"
      if config.source and not config.compress
        @fs.copy
          source: "#{config.source}"
          target: "#{target}"
      if config.source and config.compress
        @tools.compress
          format: "#{compress}"
          source: "#{config.source}"
          target: "#{target}"
      if config.command
        @execute
          command: "#{config.command} > #{target}"
      base_dir: config.target
      name: config.name
      filename: filename
      target: target
          
## Handler

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    dayjs = require 'dayjs'
    dayjs.extend require 'dayjs/plugin/utc'
    dayjs.extend require 'dayjs/plugin/timezone'

[backmeup]: https://github.com/adaltas/node-backmeup
