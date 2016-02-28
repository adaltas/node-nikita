
# `wait_connect(options, callback)`

Check if one or multiple hosts listen one or multiple ports periodically and
continue once all the connections succeed. Status will be set to "false" if the
user connections succeed right away, considering that no change had occured.
Otherwise it will be set to "true".   

## Options

*   `host`, `hosts` (array|string)    
    One or multiple host, used to build or enrich the 'servers' option.   
*   `interval` (number)    
    Time in millisecond between each connection attempt.   
*   `quorum` (number|boolean)    
    Number of minimal successful connection, 50%+1 if "true".   
    timeout, default to "/tmp".   
*   `port`, `ports` (array|string)    
    One or multiple ports, used to build or enrich the 'servers' option.   
*   `randdir`   
    Directory where to write temporary file used internally to triger a 
*   `server`, `servers` (array|object|string)    
    One or multiple servers, string must be in the form of "{host}:{port}",
    object must have the properties "host" and "port".   
*   `timeout`   
    Maximum time to wait until this function is considered to have failed.   

Example:

```coffee
require 'mecano'
.wait_connect
  hosts: [ '1.domain.com', '2.domain.com' ]
  port: 80
.then (err, status) ->
  # Servers listening on port 80
```

```coffee
require 'mecano'
.wait_connect
  host: 'my.domain.com'
  ports: [80, 443]
.then (err, status) ->
  # Server listening on ports 80 and 443
```

```coffee
require 'mecano'
.wait_connect
  servers: [
    {host: '1.domain.com', port: 80}
    {host: '2.domain.com', port: 443}
  ]
.then (err, status) ->
  # Servers listening
```

    inc = 0
    module.exports = (options, callback) ->
      extract_servers = (options) ->
        for k in ['host', 'hosts']
          options[k] ?= []
          throw error "Invalid option '#{options[k]}'" if typeof options[k] not in ['string', 'object']
          options[k] = [options[k]] unless Array.isArray options[k]
        hosts = [options.host..., options.hosts...]
        for k in ['port', 'ports']
          options[k] ?= []
          throw error "Invalid option '#{options[k]}'" if typeof options[k] not in ['string', 'number', 'object']
          options[k] = [options[k]] unless Array.isArray options[k]
        ports = [options.port..., options.ports...]
        servers = []
        for host in hosts
          for port in ports
            servers.push host: host, port: port
        servers
      servers = extract_servers options
      for k in ['server', 'servers']
        options[k] ?= []
        throw error "Invalid option '#{options[k]}'" if typeof options[k] not in ['string', 'object']
        if typeof options[k] is 'string'
          [host, port] = options[k].split ':'
          options[k] = host: host, port: port
        options[k] = [options[k]] unless Array.isArray options[k]
        options[k] = misc.array.flatten options[k]
        for server in options[k]
          servers.push extract_servers(server)...
      return callback() unless servers.length
      options.randdir ?= '/tmp'
      options.interval ?= 2000
      options.interval = Math.round options.interval / 1000
      quorum_target = options.quorum
      if quorum_target and quorum_target is true  
        quorum_target = Math.ceil servers.length / 2
      else unless quorum_target?
        quorum_target = servers.length
      quorum_current = 0
      randfiles = []
      modified = false
      each servers
      .parallel true # Make sure we dont hit max listeners limit
      .call (server, next) =>
        count = 0
        rand = Date.now() + inc++
        randfiles.push randfile = "#{options.randdir}/#{rand}"
        if options.timeout and options.timeout > 0
          timedout = false
          clear = setTimeout =>
            timedout = true
            @child().remove destination: randfile
          , options.timeout
        options.log message: "Start wait for #{server.host}:#{server.port}", level: 'DEBUG', module: 'mecano/wait/connect'
        options.wait?.call @, server
        # dont exit loop until rand file is removed or connection succeed
        child = @child()
        child.execute
          cmd: """
          count=0
          randfile="#{randfile}"
          isopen="echo > /dev/tcp/#{server.host}/#{server.port}"
          touch "$randfile"
          while [[ -f "$randfile" ]] && ! `bash -c "$isopen"`; do
            ((count++))
            echo #{server.host}:#{server.port} attempt $count > /dev/fd/2 
            sleep #{options.interval}
          done
          if [[ count -eq 0 ]]; then exit 3; fi
          """
          shy: true
          code_skipped: 3
        , (err, executed) =>
          clearTimeout clear if clear
          err = new Error "Reached timeout #{options.timeout}" if not err and timedout
          options.ready?.call @, server, executed unless err
          modified = true if executed
          options.log message: "Finish wait for #{server.host} #{server.port}", level: 'INFO', module: 'mecano/wait/connect'
          quorum_current++ unless err
          cmd = for randfile in randfiles then "rm #{randfile};"
          child.execute
            cmd: cmd.join '\n'
            shy: true
            if: quorum_current >= quorum_target
          , ->
            next err
      .then (err) ->
        callback err, modified

## Dependencies

    each = require 'each'
    misc = require '../misc'
