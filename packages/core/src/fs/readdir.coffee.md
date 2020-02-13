
# `nikita.fs.readdir(options, callback)`

Reads the contents of a directory. The implementation is conformed with the
Node.js native
[`fs.readir`](https://nodejs.org/api/fs.html#fs_fs_readdir_path_options_callback)
function.

## Options

* `target` (string)   
  Path of the directory to read; required.
* `withFileTypes` (boolean)   
  Result contain fs.Dirent objects.
  
## Output parameters

* `files` ([fs.Dirent])   
  List of the names of the files in the directory excluding '.' and '..'

## Exemples

Return an array of files if only the target options is provided:

```js
require('nikita')
.fs.mkdir('/parent/dir/a_dir')
.fs.writeFile('/parent/dir/a_file', '')
.fs.readdir("/parent/dir/a_dir", function(err, {files}){
  assert(files, ['my_dir', 'my_file'])
})
```

Return an array of `Dirent` objects if the `withFileTypes` options is provided:

```js
require('nikita')
.fs.writeFile('/parent/dir/a_file', '')
.fs.readdir({
  target: "/parent/dir/a_dir",
  withFileTypes: true
}, function(err, {files}){
  assert(files[0].name, 'a_file'
  assert(files[0].isFile(), true)
})
```

## Schema

    schema =
      type: 'object'
      properties:
        target: type: 'string'
        withFileTypes: type: 'boolean'

## Source Code

    handler = ({metadata, options}, callback) ->
      @log message: "Entering fs.readdir", level: 'DEBUG', module: 'nikita/lib/fs/readdir'
      # Normalize options
      options.target = metadata.argument if metadata.argument?
      extended = options.extended or options.withFileTypes
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      opts = [
        '1'             # (The numeric digit ``one''.)  Force output to be one entry per line.  This is the default when output is not to a terminal.
        'a'             # Include directory entries whose names begin with a dot (.)
        'n' if extended # Display user and group IDs numerically, rather than converting to a user or group name in a long (-l) output.  This option turns on the -l option.
        # Note: -w work on macos, not on linux
        # 'w'             # Force raw printing of non-printable characters. This is the default when output is not to a terminal.
        'l' if extended
      ].join('')
      @system.execute
        cmd: """
        ls -#{opts} #{options.target}
        """
      , (err, {stdout}) ->
        if err
          err.message = [
            'Invalid command:'
            'exit code is 1,'
            'ensure the target path'
            "#{JSON.stringify options.target} exists"
            '(nikita/lib/fs/readdir)'
          ].join ' '
          throw err
        files = lines stdout
        .filter (line, i) -> not extended or i isnt 0 # First line in extended mode
        .filter (line) -> line isnt '' # Empty lines
        .map (line, i) ->
          unless extended
            name: line
          else
            [, perm,, name] = /^(.+?)\s+.*?(\d+:\d+)\s+(.+)$/.exec line
            name: name
            type: switch perm[0]
              when 'b' then constants.UV_DIRENT_BLOCK  # Block special file.
              when 'c' then constants.UV_DIRENT_CHAR   # Character special file.
              when 'd' then constants.UV_DIRENT_DIR    # Directory.
              when 'l' then constants.UV_DIRENT_LINK   # Symbolic link.
              when 's' then constants.UV_DIRENT_SOCKET # Socket link.
              when 'p' then constants.UV_DIRENT_FIFO   # FIFO.
              else          constants.UV_DIRENT_FILE # Regular file.
        .filter ({name}) -> name isnt '' and name isnt '.' and name isnt '..'
        .map (file) ->
          if extended then new Dirent(file.name, file.type) else file.name
        callback null, files: files
      @next (err) ->
        callback err if err

## Exports

    module.exports =
      handler: handler
      schema: schema
      status: false
      log: false

## Dependencies

    {lines} = require '../misc/string'
    {Dirent, constants} = require 'fs'
        
