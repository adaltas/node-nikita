
# `docker_load(options, callback)`

Load Docker images

## Options

*   `machine` (string)
    Name of the docker-machine. MANDATORY if using docker-machine
*   `source` (string)
    TAR archive source path
*   `code` (int|array)
    Expected code(s) returned by the command, int or array of int, default to 0.
*   `code_skipped`
    Expected code(s) returned by the command if it has no effect, executed will
    not be incremented, int or array of int.
*   `log`
    Function called with a log related messages.
*   `ssh` (object|ssh2)
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.
*   `stdout` (stream.Writable)
    Writable EventEmitter in which the standard output of executed commands will
    be piped.
*   `stderr` (stream.Writable)
    Writable EventEmitter in which the standard error output of executed command
    will be piped.

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

```javascript
mecano.docker({
  ssh: ssh
  destination: 'test-image.tar'
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

    module.exports = (options, callback) ->
      # Validate parameters
      return callback Error 'Missing source parameter' unless options.source?
      cmd = " load -i #{options.source}"
      # need to records the list of image to see if status is modified or not after load
      # for this we print the existing images as REPOSITORY:TAG:IMAGE
      # parse the result to record images as an array of   {'REPOSITORY:TAG:'= 'IMAGE'}
      images = {}
      delete options.cmd
      docker.exec ' images | grep -v \'<none>\' | awk \'{ print $1":"$2":"$3 }\'', options, false, (err, executed, stdout, stderr) ->
        return callback err if err
        # skip header line, wi skip it here instead of in the grep  to have
        # an array with at least one not empty line
        if string.lines(stdout).length > 1
          for image in string.lines stdout
            image = image.trim()
            if image != ''
              infos = image.split(':')
              images["#{infos[0]}:#{infos[1]}"] = "#{infos[2]}"
        docker.exec cmd, options, false, (err) ->
          return callback err if err
          docker.exec ' images | grep -v \'<none>\' | awk \'{ print $1":"$2":"$3 }\'', options, false, (err, executed, out, stderr) ->
            return allback err, executed, out, stderr if err
            new_images = {}
            diff = false
            if string.lines(stdout).length > 1
              for image in string.lines out.toString()
                if image != ''
                  infos = image.split(':')
                  new_images["#{infos[0]}:#{infos[1]}"] = "#{infos[2]}"
            for new_k, new_image of new_images
              if !images[new_k]?
                diff = true
                break;
              else
                for k, image of images
                  if image != new_image && new_k == k
                    diff = true
                    break;
            return callback err, diff, stdout, stderr


## Modules Dependencies

    docker = require '../misc/docker'
    string = require '../misc/string'
    util = require 'util'
