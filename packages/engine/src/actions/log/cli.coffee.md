
# `nikita.log.cli`

Write log to the host filesystem in a user provided format.

## Configuration

* `depth_max` (number|boolean)    
* `divider` (string)    
* `end` (boolean)    
* `enabled` (boolean)    
* `host` (string)    
* `pad` (string)    
* `time` (boolean)    
  Print time.   
* `separator` (string|object)    
* `stream` (stream.Writable)  

Global config can be alternatively set with the "log_cli" property.

## Example with the depth_max option

```js
nikita
.log.cli({
  colors: true,
  depth_max: 2
})
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
    })
  })
})
```

## Example with global config

```js
nikita
.log.cli({ colors: true })
.call({
  header: 'Print my header'
}, function(){
  // do sth
})
```

## Handler

    handler = ({config, metadata, ssh}) ->
      # Normalize
      config.enabled ?= metadata.argument if metadata.argument?
      config.enabled ?= true
      config.stream ?= process.stderr
      config.end ?= false
      config.divider ?= ' : '
      config.depth_max ?= false
      config.pad ?= {}
      config.time ?= true
      config.separator = host: config.separator, header: config.separator if typeof config.separator is 'string'
      config.separator = {}
      config.separator.host ?= unless config.pad.host? then '   ' else ' '
      config.separator.header ?= unless config.pad.header? then '   ' else ' '
      config.separator.time ?= unless config.pad.time? then '  ' else ' '
      config.host ?= if ssh then ssh.config.host else 'localhost'
      config.colors ?= process.stdout.isTTY
      config.colors = {
        status_true: colors.green
        status_false: colors.cyan.dim
        status_error: colors.red
      } if config.colors is true
      # Events
      ids = {}
      format_line = ({host, header, status, time}) ->
        host = pad host, config.pad.host if config.pad.host
        header = pad header, config.pad.header if config.pad.header
        time = pad time, config.pad.time if config.pad.time
        [
          host, config.separator.host
          header, config.separator.header
          status, if config.time then config.separator.time else ''
          time
        ].join ''
      @call stream, config: config, serializer:
        'nikita:action:start': (act) ->
          return unless config.enabled
          headers = get_headers act
          return if config.depth_max and config.depth_max < headers.length
          ids[act.metadata.index] = act
          null
        # 'diff': null
        'nikita:session:resolved': ->
          color = if config.colors
          then config.colors.status_true
          else false
          line = format_line
            host: config.host
            header: ''
            status: '♥'
            time: ''
          line = color line if color
          return line+'\n'
        'nikita:session:rejected': ({error}) ->
          color = if config.colors
          then config.colors.status_error
          else false
          line = format_line
            host: config.host
            header: '' # error.message
            status: '✘'
            time: ''
          line = color line if color
          return line+'\n'
        # 'header': (log) ->
        #   return unless config.enabled
        #   return if config.depth_max and config.depth_max < log.metadata.headers.length
        #   ids[log.index] = log
        #   null
        # 'lifecycle': (log) ->
        #   return unless ids[log.index]
        #   ids[log.index].disabled = true if log.message in ['conditions_failed', 'disabled_true']
        #   null
        'nikita:action:end': (action, error, output) ->
          return unless action.config.header
          return if config.depth_max and config.depth_max < action.metadata.depth
          # TODO: I don't like this, the `end` event should receive raw output
          # with error not placed inside output by the history plugin
          error = error or action.metadata.relax and output.error
          status = if error then '✘' else if output?.status and not action.metadata.shy then '✔' else '-'
          color = false
          if config.colors
            color = if error then config.colors.status_error
            else if output.status then config.colors.status_true
            else config.colors.status_false
          # action = ids[action.index]
          return null if action.metadata.disabled
          # delete ids[action.index]
          time = if config.time then utils.string.print_time Date.now() - action.metadata.time else ''
          headers = get_headers action
          line = format_line
            host: config.host
            header: headers.join config.divider
            status: status
            time: time
          line = color line if color
          return line+'\n'
        # 'stdin': null
        # 'stderr': null
        # 'stdout': null
        # 'text': null

## Exports

    module.exports =
      ssh: false
      handler: handler

## Dependencies

    colors = require 'colors/safe'
    pad = require 'pad'
    stream = require './stream'
    utils = require '../../utils'

    get_headers = (action) ->
      walk = (parent) ->
        precious = parent.config.header
        results = []
        results.push precious unless precious is undefined
        results.push ...(walk parent.parent) if parent.parent
        results
      headers = walk action
      headers.reverse()
