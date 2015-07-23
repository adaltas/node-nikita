
# `docker_start(options, callback)`

Start stopped containers

## Options

*   `container` (string)
    Name/ID of the container. MANDATORY
*   `machine` (string)
    Name of the docker-machine. MANDATORY if using docker-machine
*   `attach` (boolean)
    attach STDOUT/STDERR. False by default

## Callback parameters

*   `err`
    Error object if any.
*   `executed`
    if command was executed
*   `stdout`
    Stdout value(s) unless `stdout` option is provided.
*   `stderr`
    Stderr value(s) unless `stderr` option is provided.

## Example

1- builds an image from dockerfile without any resourcess

```javascript
mecano.docker_start({
  name: 'toto',
  attach: true
}, function(err, is_true, stdout, stderr){
  if(err){
    console.log(err.message);
  }else if(is_true){
    console.log('OK!');
  }else{
    console.log('Ooops!');
  }
})
```

## Source Code

    module.exports = (options, callback) ->
      # Validate parameters
      return callback Error 'Missing container parameter' unless options.container?
      # rm is false by default only if options.service is true
      docker.get_provider options, (err,  provider) =>
        return callback err if err
        options.provider = provider
        cmd = docker.prepare_cmd provider, options.machine
        cmd += 'docker start '
        cmd += '-a ' if options.attach
        exec_opts =
        cmd += options.container
          cmd: cmd
        for k in ['ssh','log', 'stdout','stderr','cwd','code','code_skipped']
          exec_opts[k] = options[k] if options[k]?
        @execute exec_opts, (err, executed, stdout, stderr) -> callback err, executed, stdout, stderr

## Modules Dependencies

    docker = require './misc/docker'
