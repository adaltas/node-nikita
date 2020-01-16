// Generated by CoffeeScript 2.5.0
  // # `nikita.docker.build`

// Build docker repository from Dockerfile, from content or from current working
  // directory (exclusive options).

// The user can choose whether the build is local or on the remote.
  // Options are the same than docker build command with nikita's one.
  // Be aware than you can not use ADD with content option because docker build
  // from STDIN does not support a context.

// By default docker always run the build and overwrite existing repositories.
  // Status unmodified if the repository is identical to a previous one

// ## Options

// * `boot2docker` (boolean)   
  //   Whether to use boot2docker or not, default to false.
  // * `image` (string)   
  //   Name of the image, required.
  // * `tag` (string)   
  //   Tag of the image.
  // * `machine` (string)   
  //   Name of the docker-machine, required if using docker-machine.
  // * `file`   
  //   Path to Dockerfile.
  // * `content` (string | [string])   
  //   Use this text to build the repository.
  // * `quiet` (boolean)   
  //   Suppress the verbose output generated by the containers. Default to false
  // * `rm` (boolean)   
  //   Remove intermediate containers after build, default to true.
  // * `force_rm` (boolean)   
  //   Always remove intermediate containers during build, default to false.
  // * `no_cache` (boolean)   
  //   Do not use cache when building the repository, default to false.
  // * `build_arg` ("k=v" | [])   
  //   Send arguments to the build (Must match an ARG command).
  // * `cwd` (string)   
  //   change the working directory for the build.

// ## Callback parameters

// * `err`   
  //   Error object if any.   
  // * `status`   
  //   True if image was successfully built.   
  // * `image`   
  //   Image ID if the image was built, the ID is based on the image sha256 checksum.   
  // * `stdout`   
  //   Stdout value(s) unless `stdout` option is provided.   
  // * `stderr`   
  //   Stderr value(s) unless `stderr` option is provided.   

// ## Examples

// ### Builds a repository from dockerfile without any resourcess

// ```javascript
  // require('nikita')
  // .docker.build({
  //   image: 'ryba/targe-build',
  //   source: '/home/ryba/Dockerfile'
  // }, function(err, {status}){
  //   console.log( err ? err.message : 'Container built: ' + status);
  // });
  // ```

// ### Builds an repository from dockerfile with external resources

// In this case nikita download all the external files into a resources directory in the same location
  // than the Dockerfile. The Dockerfile content:

// ```dockerfile
  // FROM centos7
  // ADD resources/package.tar.gz /tmp/
  // ADD resources/configuration.sh /tmp/
  // ```

// Build directory tree :

// ```
  // ├── Dockerfile
  // ├── resources
  // │   ├── package.tar.gz
  // │   ├── configuration.sh
  // ```

// ```javascript
  // require('nikita')
  // .docker.build({
  //   tag: 'ryba/target-build',
  //   source: '/home/ryba/Dockerfile',
  //   resources: ['http://url.com/package.tar.gz/','/home/configuration.sh']
  // }, function(err, {status}){
  //   console.log( err ? err.message : 'Container built: ' + status);
  // });
  // ```

// ### Builds an repository from stdin

// ```javascript
  // require('nikita')
  // .docker.build({
  //   ssh: ssh,
  //   tag: 'ryba/target-build'
  //   content: "FROM ubuntu\nRUN echo 'helloworld'"
  // }, function(err, {status}){
  //   console.log( err ? err.message : 'Container built: ' + status);
  // });
  // ```

// ## Source Code
var docker, path, string, util,
  indexOf = [].indexOf;

module.exports = function({options}, callback) {
  var cmd, dockerfile_cmds, i, j, k, l, len, len1, len2, number_of_step, opt, ref, ref1, ref2, ref3, source, ssh, userargs, v;
  this.log({
    message: "Entering Docker build",
    level: 'DEBUG',
    module: 'nikita/lib/docker/build'
  });
  // SSH connection
  ssh = this.ssh(options.ssh);
  // Global options
  if (options.docker == null) {
    options.docker = {};
  }
  ref = options.docker;
  for (k in ref) {
    v = ref[k];
    if (options[k] == null) {
      options[k] = v;
    }
  }
  if (options.image == null) {
    // Validation
    return callback(Error('Required option "image"'));
  }
  if ((options.content != null) && (options.file != null)) {
    return callback(Error('Can not build from Dockerfile and content'));
  }
  if (options.rm == null) {
    options.rm = true;
  }
  cmd = 'build';
  number_of_step = 0;
  userargs = [];
  // status unmodified if final tag already exists
  dockerfile_cmds = ['CMD', 'LABEL', 'EXPOSE', 'ENV', 'ADD', 'COPY', 'ENTRYPOINT', 'VOLUME', 'USER', 'WORKDIR', 'ARG', 'ONBUILD', 'RUN', 'STOPSIGNAL', 'MAINTAINER'];
  source = null;
  if (options.file) {
    source = options.file;
  } else if (options.cwd) {
    source = `${options.cwd}/Dockerfile`;
  }
  if (options.file) {
    if (options.cwd == null) {
      options.cwd = path.dirname(options.file);
    }
  }
  ref1 = ['force_rm', 'quiet', 'no_cache'];
  // Apply search and replace to content
  // options.write ?= []
  // if options.from? or options.to? or options.match? or options.replace? or options.before?
  //   options.write.push
  //     from: options.from
  //     to: options.to
  //     match: options.match
  //     replace: options.replace
  //     append: options.append
  //     before: options.before
  //   options.append = false
  // Build cmd
  for (i = 0, len = ref1.length; i < len; i++) {
    opt = ref1[i];
    if (options[opt]) {
      cmd += ` --${opt.replace('_', '-')}`;
    }
  }
  ref2 = ['build_arg'];
  for (j = 0, len1 = ref2.length; j < len1; j++) {
    opt = ref2[j];
    if (options[opt] != null) {
      if (Array.isArray(options[opt])) {
        ref3 = options[opt];
        for (l = 0, len2 = ref3.length; l < len2; l++) {
          k = ref3[l];
          cmd += ` --${opt.replace('_', '-')} ${k}`;
        }
      } else {
        cmd += ` --${opt.replace('_', '-')} ${options[opt]}`;
      }
    }
  }
  cmd += ` --rm=${options.rm ? 'true' : 'false'}`;
  cmd += ` -t \"${options.image}${options.tag ? `:${options.tag}` : ''}\"`;
  if (options.cwd) {
    // custom command for content option0
    if (options.file == null) {
      options.file = path.resolve(options.cwd, 'Dockerfile');
    }
  }
  if (options.content != null) {
    this.log({
      message: "Building from text: Docker won't have a context. ADD/COPY not working",
      level: 'WARN',
      module: 'nikita/docker/build'
    });
    if (options.content != null) {
      cmd += ` - <<DOCKERFILE\n${options.content}\nDOCKERFILE`;
    }
  } else if (options.file != null) {
    this.log({
      message: `Building from Dockerfile: \"${options.file}\"`,
      level: 'INFO',
      module: 'nikita/docker/build'
    });
    cmd += ` -f ${options.file} ${options.cwd}`;
  } else {
    this.log({
      message: "Building from CWD",
      level: 'INFO',
      module: 'nikita/docker/build'
    });
    cmd += ' .';
  }
  this.file({
    if: options.content,
    content: options.content,
    source: source,
    target: function(content) {
      return options.content = content;
    },
    from: options.from,
    to: options.to,
    match: options.match,
    replace: options.replace,
    append: options.append,
    before: options.before,
    write: options.write
  });
  this.call({ // Read Dockerfile if necessary to count steps
    unless: options.content
  }, function(_, callback) {
    this.log({
      message: `Reading Dockerfile from : ${options.file}`,
      level: 'INFO',
      module: 'nikita/lib/build'
    });
    return this.fs.readFile({
      ssh: options.ssh,
      target: options.file,
      encoding: 'utf8'
    }, function(err, {data}) {
      if (err) {
        return callback(err);
      }
      options.content = data;
      return callback();
    });
  });
  this.call(function() { // Count steps
    var len3, line, m, ref4, ref5, ref6, results;
    ref4 = string.lines(options.content);
    results = [];
    for (m = 0, len3 = ref4.length; m < len3; m++) {
      line = ref4[m];
      if (ref5 = (ref6 = /^(.*?)\s/.exec(line)) != null ? ref6[1] : void 0, indexOf.call(dockerfile_cmds, ref5) >= 0) {
        results.push(number_of_step++);
      } else {
        results.push(void 0);
      }
    }
    return results;
  });
  this.system.execute({
    cmd: docker.wrap(options, cmd),
    cwd: options.cwd
  }, function(err, {stdout, stderr}) {
    var image_id, line, lines, number_of_cache;
    if (err) {
      throw err;
    }
    image_id = null;
    // lines = string.lines stderr
    lines = string.lines(stdout);
    number_of_cache = 0;
    for (k in lines) {
      line = lines[k];
      if (line.indexOf('Using cache') !== -1) {
        number_of_cache = number_of_cache + 1;
      }
      if (line.indexOf('Successfully built') !== -1) {
        image_id = line.split(' ').pop().toString();
      }
    }
    return userargs = {
      status: number_of_step !== number_of_cache,
      image: image_id,
      stdout: stdout,
      stderr: stderr
    };
  });
  return this.next(function(err) {
    if (err) {
      return callback(err);
    }
    this.log(userargs.status ? {
      message: `New image id ${userargs[1]}`,
      level: 'INFO',
      module: 'nikita/lib/docker/build'
    } : {
      message: `Identical image id ${userargs[1]}`,
      level: 'INFO',
      module: 'nikita/lib/docker/build'
    });
    return callback(null, userargs);
  });
};

// ## Modules Dependencies
docker = require('@nikitajs/core/lib/misc/docker');

string = require('@nikitajs/core/lib/misc/string');

path = require('path');

util = require('util');
