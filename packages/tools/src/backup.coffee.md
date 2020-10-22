
# `nikita.tools.backup`

Backup a file, a directory or the output of a command.

## Options

* `name` (string)   
  Backup file name, required.   
* `cmd` (string)      
  Command from which to pipe the ouptut or generating a file if the "target" 
  option is defined.   
* `format` (string)   
  Format used to name the backup directory, used by [Moment.js], default to 
  "ISO-8601".   
* `locale` (string)   
  Locale used to name the backup directory, used by [Moment.js], default to 
  UTC.   
* `compress`   
  One of "tgz", "tar", "xz", "bz2" or "zip", default to "tgz" if true or a directory otherwise no compression.   
* `source` (string)   
  Path to a file or a directory to backup.   
* `target` (string)
  Directory storing the backup, required.

## Callback parameters

* `err` (Error)   
  Error object if any.   
* `status`  (boolean)   
  Value is "true" if backup was created.   
* `base_dir` (string)   
* `name` (string)   
* `filename` (string)   
* `target` (string)   

## Backup a directory

```js
require('nikita')
.tools.backup({
  name: 'my_backup'
  source: '/etc'
  target: '/tmp/backup'
  algorithm: 'gzip' # Value are "gzip", "bzip2", "xz" or "none"
  extension: 'tgz'
  # retention: {
  #   count: 3
  #   date: '2015-01-01-00:00:00'
  #   age: month: 2
  # }
}, function(err, {status, info}){
  console.info(info);
});
```

## Source code

    module.exports = ({options}, callback) ->
      @log message: "Entering backup", level: 'DEBUG', module: 'nikita/lib/tools/backup'
      throw  Error 'Missing option: "target"' unless options.target
      throw  Error 'Missing option: "name"' unless options.name
      m = moment()
      if options.locale then m.locale(options.locale) else m.utc()
      filename = m.format(options.format)
      target = "#{options.target}/#{options.name}/#{filename}"
      compress = options.compress
      compress = 'tgz' if compress is true or not compress
      @log message: "Source is #{JSON.stringify options.source}", level: 'INFO', module: 'nikita/lib/tools/backup'
      @log message: "Target is #{JSON.stringify target}", level: 'INFO', module: 'nikita/lib/tools/backup'
      @system.mkdir "#{path.dirname target}"
      @call if: options.source, ->
        @system.copy
          if: options.source
          # if_exec: "[ -f #{options.source} ]"
          unless: options.compress
          target: "#{target}"
          source: "#{options.source}"
        @tools.compress
          source: "#{options.source}"
          target: "#{target}.#{compress}"
          format: "#{compress}"
          if: -> options.compress
        , (err) ->
          throw err unless err
          filename = "#{filename}.tgz"
      @system.execute
        cmd: "#{options.cmd} > #{target}"
        if: options.cmd
      @next (err, {status}) ->
        callback err,
          status: status,
          base_dir: options.target
          name: options.name
          filename: filename
          target: target

## Dependencies

    moment = require 'moment'
    path = require 'path'

[backmeup]: https://github.com/adaltas/node-backmeup
