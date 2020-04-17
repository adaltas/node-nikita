
# `nikita.fs.createReadStream`

## Example

```js
buffers = []
await require('nikita')
.fs.createReadStream({
  target: '/path/to/file'
  stream: function(rs){
    stream.on('readable', function(){
      while(buffer = rs.read()){
        buffers.push(buffer);
      }
    })
  }
})
console.info(Buffer.concat(buffers).toString())
```

```js
buffers = []
await require('nikita')
.fs.createReadStream({
  target: '/path/to/file'
  on_readable: function(rs){
    while(buffer = rs.read()){
      buffers.push(buffer);
    }
  }
})
console.info(Buffer.concat(buffers).toString())
```

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## schema

    schema =
      type: 'object'
      properties:
        'encoding':
          type: 'string'
          enum: require('../../utils/schema').encodings
          default: 'utf8'
          description: """
          The encoding used to decode the buffer into a string. The encoding can
          be any one of those accepted by Buffer. When not defined, this action
          return a Buffer instance.
          """
        'stream':
          typeof: 'function'
          description: """
          User provided function receiving the newly created readable stream.
          The user is responsible for pumping new content from it.
          """
        'target':
          oneOf: [{type: 'string'}, 'instanceof': 'Buffer']
          description: """
          Source location of the file to read.
          """
      required: ['target']

## Source Code

    handler = ({config, hooks, metadata, ssh}) ->
      @log message: "Entering fs.createReadStream", level: 'DEBUG', module: 'nikita/lib/fs/createReadStream'
      p = if ssh then path.posix else path
      # Normalization
      # throw Error "Required Option: the \"target\" option is mandatory" unless config.target
      config.target = if config.cwd then p.resolve config.cwd, config.target else p.normalize config.target
      throw Error "Non Absolute Path: target is #{JSON.stringify config.target}, SSH requires absolute paths, you must provide an absolute path in the target or the cwd option" if ssh and not p.isAbsolute config.target
      config.target_tmp ?= "#{metadata.tmpdir}/#{string.hash config.target}" if config.sudo
      throw error 'NIKITA_FS_CRS_NO_EVENT_HANDLER', [
        'unable to consume the readable stream,'
        'one of the "on_readable" or "stream"'
        'hooks must be provided'
      ] unless hooks.on_readable or config.stream
      # Guess current username
      current_username =
        if ssh then ssh.config.username
        else if /^win/.test(process.platform) then process.env['USERPROFILE'].split(path.sep)[2]
        else process.env['USER']
      try if config.target_tmp
        await @system.execute
          bash: config.bash
          arch_chroot: config.arch_chroot
          cmd: """
          [ ! -f '#{config.target}' ] && exit
          cp '#{v.target}' '#{config.target_tmp}'
          chown '#{current_username}' '#{config.target_tmp}'
          """
        @log message: "Placing original file in temporary path before reading", level: 'INFO', module: 'nikita/lib/fs/createReadStream'
      catch err
        @log message: "Failed to place original file in temporary path", level: 'ERROR', module: 'nikita/lib/fs/createReadStream'
        throw err
      # Read the stream
      @log message: "Reading file #{config.target_tmp or config.target}", level: 'DEBUG', module: 'nikita/lib/fs/createReadStream'
      new Promise (resolve, reject) ->
        buffers = []
        rs = await fs.createReadStream ssh, config.target_tmp or config.target
        if hooks.on_readable
        then rs.on 'readable', -> hooks.on_readable rs
        else config.stream rs
        rs.on 'error', (err) ->
          # "NIKITA_FS_CWS_TARGET_INVALID: fail to write a file, location is \"#{tmpdir}/a_dir/a_file\""
          if err.code is 'ENOENT'
            err = error 'NIKITA_FS_CRS_TARGET_ENOENT', [
              'fail to read a file because it does not exist,'
              unless config.target_tmp
              then "location is #{JSON.stringify config.target}."
              else "location is #{JSON.stringify config.target_tmp} (temporary file, target is #{JSON.stringify config.target})."
            ],
              errno: err.errno
              code: 'NIKITA_FS_CRS_TARGET_ENOENT'
              syscall: err.syscall
              path: err.path
          else if err.code is 'EISDIR'
            err = error 'NIKITA_FS_CRS_TARGET_EISDIR', [
              'fail to read a file because it is a directory,'
              unless config.target_tmp
              then "location is #{JSON.stringify config.target}."
              else "location is #{JSON.stringify config.target_tmp} (temporary file, target is #{JSON.stringify config.target})."
            ],
              errno: err.errno
              code: 'NIKITA_FS_CRS_TARGET_EISDIR'
              syscall: err.syscall
              path: config.target_tmp or config.target # Native Node.js api doesn't provide path
          reject err
        rs.on 'end', resolve

## Exports

    module.exports =
      handler: handler
      on_action: on_action
      metadata:
        status: false
        log: false
        tmpdir: true
      schema: schema

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    string = require '../../utils/string'
    error = require '../../utils/error'
