
# `nikita.connection.wait`

Check if one or multiple hosts listen one or multiple ports periodically and
continue once all the connections succeed. Status will be set to "false" if the
user connections succeed right away, considering that no change had occured.
Otherwise it will be set to "true".   

## Options

* `host`, `hosts` (array|string)  
  One or multiple hosts, used to build or enrich the 'servers' option.
* `interval` (number)  
  Time in millisecond between each connection attempt.
* `quorum` (number|boolean)  
  Number of minimal successful connection, 50%+1 if "true".    
* `port`, `ports` (array|string)  
  One or multiple ports, used to build or enrich the 'servers' option.
* `randdir`   
  Directory where to write temporary file used internally to triger a 
* `server`, `servers` (array|object|string)  
  One or multiple servers, string must be in the form of "{host}:{port}",
  object must have the properties "host" and "port".
* `timeout` (number)   
  Maximum time to wait until this function is considered to have failed.

Status is set to "true" if the first connection attempt was a failure and the 
connection finaly succeeded.

## TODO

The `server` and `servers` options shall be renamed `address` and `addresses`.

## Examples

Wait for two domains on the same port.

```js
require('nikita')
.wait_connect({
  hosts: [ '1.domain.com', '2.domain.com' ],
  port: 80
}, function(err, {status}){
  // Servers listening on port 80
})
```

Wait for one domain on two diffents ports.

```js
require('nikita')
.wait_connect({
  host: 'my.domain.com',
  ports: [80, 443]
}, function(err, {status}){
  // Server listening on ports 80 and 443
})
```

Wait for two domains on diffents ports.

```js
require('nikita')
.wait_connect({
  servers: [
    {host: '1.domain.com', port: 80},
    {host: '2.domain.com', port: 443}
  ]
}, function(err, {status}){
  // Servers listening
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering wait for connection", level: 'DEBUG', module: 'nikita/connection/wait'
      extract_servers = (options) ->
        throw Error "Invalid host: #{options.host}" if (options.port or options.ports) and not options.host
        throw Error "Invalid port: #{options.port}" if (options.host or options.hosts) and not options.port
        for k in ['host', 'hosts']
          options[k] ?= []
          throw Error "Invalid option '#{options[k]}'" if typeof options[k] not in ['string', 'object']
          options[k] = [options[k]] unless Array.isArray options[k]
        hosts = [options.host..., options.hosts...]
        for k in ['port', 'ports']
          options[k] ?= []
          throw Error "Invalid option '#{options[k]}'" if typeof options[k] not in ['string', 'number', 'object']
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
        throw Error "Invalid option '#{options[k]}'" if typeof options[k] not in ['string', 'object']
        if typeof options[k] is 'string'
          [host, port] = options[k].split ':'
          options[k] = host: host, port: port
        options[k] = [options[k]] unless Array.isArray options[k]
        options[k] = array.flatten options[k]
        for server in options[k]
          servers.push extract_servers(server)...
      unless servers.length
        @log message: "No connection to wait for", level: 'WARN', module: 'nikita/connection/wait'
        return 
      # Validate servers
      options.interval ?= 2000 # 2s
      options.interval = Math.round options.interval / 1000
      quorum_target = options.quorum
      if quorum_target and quorum_target is true  
        quorum_target = Math.ceil servers.length / 2
      else unless quorum_target?
        quorum_target = servers.length
      options.timeout = '' unless options.timeout > 0
      @system.execute
        bash: true
        cmd: """
        function compute_md5 {
          echo $1 | openssl md5 | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'
        }
        addresses=( #{servers.map((server) -> "'#{server.host}:#{server.port}'").join(' ')} )
        timeout=#{options.timeout or ''}
        md5=`compute_md5 ${addresses[@]}`
        randdir="#{options.randdir or ''}"
        if [ -z $randir ]; then
          if [ -w /dev/shm ]; then
            randdir="/dev/shm/$md5"
          else
            randdir="/tmp/$md5"
          fi
        fi
        quorum_target=#{quorum_target}
        echo "[INFO] randdir is: $randdir"
        mkdir -p $randdir
        echo 3 > $randdir/signal
        echo 0 > $randdir/quorum
        function remove_randdir {
          for address in "${addresses[@]}" ; do
            host="${address%%:*}"
            port="${address##*:}"
            rm -f $randdir/`compute_md5 $host:$port`
          done
        }
        function check_quorum {
          quorum_current=`cat $randdir/quorum`
          if [ $quorum_current -ge $quorum_target ]; then
            echo '[INFO] Quorum is reached'
            remove_randdir
          fi
        }
        function check_timeout {
          local timeout=$1
          local randfile=$2
          wait $timeout # really? shall be sleep, isn't it
          rm -f $randfile
        }
        function wait_connection {
          local host=$1
          local port=$2
          local randfile=$3
          local count=0
          echo "[DEBUG] Start wait for $host:$port"
          isopen="echo > '/dev/tcp/$host/$port'"
          touch "$randfile"
          while [[ -f "$randfile" ]] && ! `bash -c "$isopen" 2>/dev/null`; do
            ((count++))
            echo "[DEBUG] Connection failed to $host:$port on attempt $count" >&2
            sleep #{options.interval}
          done
          if [[ -f "$randfile" ]]; then
            echo "[DEBUG] Connection ready to $host:$port"
          fi
          echo $(( $(cat $randdir/quorum) + 1 )) > $randdir/quorum
          check_quorum
          if [ "$count" -gt "0" ]; then
            echo "[WARN] Status is now active, count is $count"
            echo 0 > $randdir/signal
          fi
        }
        if [ ! -z "$timeout" ]; then
          host="${address%%:*}"
          port="${address##*:}"
          check_timeout $timeout `compute_md5 $host:$port` &
        fi
        for address in "${addresses[@]}" ; do
          host="${address%%:*}"
          port="${address##*:}"
          randfile=$randdir/`compute_md5 $host:$port`
          wait_connection $host $port $randfile &
        done
        wait
        # Clean up
        signal=`cat $randdir/signal`
        remove_randdir
        echo "[INFO] Exit code is $signal"
        exit $signal
        """
        code_skipped: 3
        stdin_log: false

## Dependencies

    array = require '../misc/array'
