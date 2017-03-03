
# `nikita.docker.status(options, [callback])`

Return true if container is running. This function is not native to docker. 

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `container` (string|array). __Mandatory__   
    Name or Id of the container.   
*   `machine` (string)   
    Name of the docker-machine. __Mandatory__ if using docker-machine   

## Callback parameters

*   `err`   
    Error object if any.   
*   `executed`   
    Wether the container is running or not.   
*   `stdout`   
    Stdout value(s) unless `stdout` option is provided.   
*   `stderr`   
    Stderr value(s) unless `stderr` option is provided.   

## Example

```javascript
nikita.docker({
  ssh: ssh
  target: 'test-image.tar'
  image: 'test-image'
  compression: 'gzip'
  entrypoint: '/bin/true'
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

    module.exports = (options) ->
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      throw Error 'Missing container parameter' unless options.container?
      # Construct exec command
      cmd = "ps | grep '#{options.container}'"
      @system.execute
        cmd: docker.wrap options, cmd
        code_skipped: 1
      , docker.callback

## Modules Dependencies

    docker = require '../misc/docker'
