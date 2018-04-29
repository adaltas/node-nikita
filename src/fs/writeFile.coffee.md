
# `nikita.fs.writeFile(options, callback)`

Options include

* `content` (string|buffer)   
  Content to write.
* `flags` (string)   
  File flags, see [open(2)](http://man7.org/linux/man-pages/man2/open.2.html).
* `mode` (string|int)   
  Permission mode.
* `target` (string)   
  Final destination path.
* `target_tmp` (string)   
  Temporary file for upload before moving to final destination path.

## Source Code

    module.exports = status: false, handler: (options) ->
      options.log message: "Entering fs.writeFile", level: 'DEBUG', module: 'nikita/lib/fs/writeFile'
      ssh = @ssh options.ssh
      p = if ssh then path.posix else path
      # Default argument
      options.target = options.argument if options.argument?
      # Validation
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      # Normalization
      options.target = if options.cwd then p.resolve options.cwd, options.target else p.normalize options.target
      throw Error "Non Absolute Path: target is #{JSON.stringify options.target}, SSH requires absolute paths, you must provide an absolute path in the target or the cwd option" if ssh and not p.isAbsolute options.target
      # Real work
      @fs.createWriteStream
        target: options.target
        flags: options.flags
        mode: options.mode
        stream: (ws) ->
          ws.write options.content
          ws.end()

## Dependencies

    path = require 'path'
    fs = require 'ssh2-fs'
    string = require '../misc/string'
