
# `pidfile_running`

Check if the pid (Process Id) stored inside a file match a running process. Any
file referencing a dead process will be removed.

The callback is called with an error and a boolean indicating if the process is
running.

```js
pidfile_running ssh, pidfile, function(err, running){
  console.log(err ? err.message : 'Running: '+running);
}
```

    module.exports = (ssh, pidfile, callback) ->
      throw Error 'Argument "options" removed' if arguments.length is 4
      child = exec ssh, """
      if [ ! -f '#{pidfile}' ]; then exit 1; fi
      if ! kill -s 0 `cat '#{pidfile}'`; then
        rm '#{pidfile}';
        exit 2;
      fi
      """
      child.on 'error', callback
      child.on 'exit', (code) ->
        callback null, code is 0

## Dependencies

    exec = require 'ssh2-exec'