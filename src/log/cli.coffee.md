
# `nikita.log.cli(options, [callback])`

Write log to the host filesystem in a user provided format.

## Options

*   `depth` (number|boolean)    
*   `divider` (string)    
*   `end` (boolean)    
*   `enabled` (boolean)    
*   `host` (string)    
*   `pad` (string)    
*   `time` (boolean)    
    Print time.   
*   `separator` (string|object)    
*   `stream` (stream.Writable)  

Global options can be alternatively set with the "log.cli" property

## Exemple with the depth option

```js
require('nikita')(
  log: { cli: { colors: true } }
)
.log.cli({ depth: 2 })
.call({
  header: 'Print my header'
}, function(){
  @call({
    header: 'Print sub header'
  }, function(){
    @call({
      header: 'Header not printed'
    }, function(){
      // do sth
    });
  });
});
```

## Exemple with global options

```js
require('nikita')(
  log_cli: { colors: true }
)
.log.cli()
.call({
  header: 'Print my header'
}, function(){
  // do sth
});
```

## Source Code

    module.exports = ssh: null, handler: (options) ->
      # Obtains options from "log_cli" namespace
      options.log_cli ?= {}
      options[k] = v for k, v of options.log_cli
      # Normalize
      options.enabled ?= options.argument if options.argument?
      options.enabled ?= true
      options.stream ?= process.stdout
      options.end ?= false
      options.divider ?= ' : '
      options.depth ?= false
      options.pad ?= {}
      options.time ?= true
      options.separator = host: options.separator, header: options.separator if typeof options.separator is 'string'
      options.separator ?= {}
      options.separator.host ?= unless options.pad.host? then '   ' else ' '
      options.separator.header ?= unless options.pad.header? then '   ' else ' '
      options.separator.time ?= unless options.pad.time? then '  ' else ' '
      options.host ?= if options.ssh then options.ssh.config.host else 'localhost'
      options.colors ?= process.stdout.isTTY
      options.colors = {
        host: colors.cyan.dim
        header: colors.cyan.dim
        # final_status_error: colors.red
        # final_status_success: colors.blue
        # final_host_error: colors.red
        # final_host_success: colors.blue 
        status_true: colors.cyan
        status_false: colors.cyan
        status_error: colors.magenta
        time: colors.cyan.dim
      } if options.colors
      # Events
      ids = {}
      @call options, stream, serializer:
        'diff': null
        'end': ->
          "FINISH\n"
        'error': (err) ->
          "ERROR"
        'header': (log) ->
          return unless options.enabled
          return if options.depth and options.depth < log.headers.length
          ids[log.index] = log
          null
        "handled": (log) ->
          status = if log.error then 'x' else if log.status then '+' else '-'
          log = ids[log.index]
          return null unless log
          delete ids[log.index]
          time = if options.time then string.print_time Date.now() - log.time else ''
          host = options.host
          host_separator = options.separator.host
          header = log.headers.join(options.divider)
          header_separator = options.separator.header
          time_separator = if options.time then options.separator.time else ''
          # Padding
          host = pad host, options.pad.host if options.pad.host
          header = pad header, options.pad.header if options.pad.header
          time = pad time, options.pad.time if options.pad.time
          if options.colors
            time = options.colors.time time if options.time
            host = options.colors.host host
            host_separator = options.colors.host host_separator
            header = options.colors.header header
            header_separator = options.colors.host header_separator
            status = if log.error
            then options.colors.status_error status
            else if log.status then options.colors.status_true status
            else options.colors.status_false status
          "#{host}#{host_separator}#{header}#{header_separator}#{status}#{time_separator}#{time}\n"
        'stdin': null
        'stderr': null
        'stdout': null
        'text': null

## Dependencies

    colors = require 'colors/safe'
    pad = require 'pad'
    stream = require './stream'
    string = require '../misc/string'
