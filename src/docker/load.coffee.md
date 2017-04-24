
# `nikita.docker.load(options, [callback])`

Load Docker images

## Options

* `boot2docker` (boolean)   
  Whether to use boot2docker or not, default to false.   
* `machine` (string)   
  Name of the docker-machine. __Mandatory__ if using docker-machine   
* `input` (string)   
  TAR archive file to read from   
* `source` (string)   
  Alias for the "input" option.   
* `checksum` (string)   
  If provided, will check if attached input archive to checksum already exist.   
  Not native to docker. But implemented to get better performance.   

## Callback parameters

* `err`   
  Error object if any.   
* `executed`   
  if command was executed   
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.   
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.   

## Example

```javascript
nikita.docker.load({
  image: 'nikita/load_test:latest',
  machine: machine,
  source: source + "/nikita_load.tar"
}, function(err, loaded, stdout, stderr) {
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
      options.log message: "Entering Docker load", level: 'DEBUG', module: 'nikita/lib/docker/load'
      # Obtains options from "docker" namespace
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validate parameters
      options.input ?= options.source
      return callback Error 'Missing input parameter' unless options.input?
      cmd = "load -i #{options.input}"
      # need to records the list of image to see if status is modified or not after load
      # for this we print the existing images as REPOSITORY:TAG:IMAGE
      # parse the result to record images as an array of   {'REPOSITORY:TAG:'= 'IMAGE'}
      images = {}
      delete options.cmd
      options.log message: 'Storing previous state of image', level: 'INFO', module: 'nikita/lib/docker/load'
      options.log message: 'No checksum provided', level: 'INFO', module: 'nikita/lib/docker/load' if !options.checksum?
      options.log message: "Checksum provided :#{options.checksum}", level: 'INFO', module: 'nikita/lib/docker/load' if options.checksum
      options.checksum ?= ''
      @system.execute
        cmd: docker.wrap options, " images | grep -v '<none>' | awk '{ print $1\":\"$2\":\"$3 }'"
      , (err, executed, stdout, stderr) =>
        return callback err if err
        # skip header line, wi skip it here instead of in the grep  to have
        # an array with at least one not empty line
        if string.lines(stdout).length > 1
          for image in string.lines stdout
            image = image.trim()
            if image != ''
              infos = image.split(':')
              # if image is here we skip
              options.log message: "Image already exist checksum :#{options.checksum}, repo:tag #{"#{infos[0]}:#{infos[1]}"}", level: 'INFO', module: 'nikita/lib/docker/load' if infos[2] == options.checksum
              return callback null, false if infos[2] == options.checksum
              images["#{infos[0]}:#{infos[1]}"] = "#{infos[2]}"
        options.log message: "Start Loading #{options.input} ", level: 'INFO', module: 'nikita/lib/docker/load'
        @system.execute
          cmd: docker.wrap options, cmd
        @system.execute
          cmd: docker.wrap options, 'images | grep -v \'<none>\' | awk \'{ print $1":"$2":"$3 }\''
        , (err, executed, out, stderr) ->
          return callback err, executed, out, stderr if err
          new_images = {}
          diff = false
          options.log message: 'Comparing new images', level: 'INFO', module: 'nikita/lib/docker/load'
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
                  options.log message: 'Identical images', level: 'INFO', module: 'nikita/lib/docker/load'
                  break;
          callback err, diff, stdout, stderr


## Modules Dependencies

    docker = require '../misc/docker'
    string = require '../misc/string'
    util = require 'util'
