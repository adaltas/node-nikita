
# `nikita.file.assert(options)`

Assert a file exists or a provided text match the content of a text file.

## Options

* `content` (buffer|string)   
  Text to validate.   
* `encoding` (string)   
  Content encoding, see the Node.js supported Buffer encoding.   
* `filetype` (string|array)   
  Validate the file, could be any [file type constants](https://nodejs.org/api/fs.html#fs_file_type_constants)
  or one of 'ifreg', 'file', 'ifdir', 'directory', 'ifchr', 'chardevice', 
  'iffblk', 'blockdevice', 'ififo', 'fifo', 'iflink', 'symlink', 'ifsock', 
  'socket'.   
* `md5` (string)   
  Validate signature.   
* `mode` (string)   
  Validate file permissions.   
* `not` (boolean)   
  Negates the validation.   
* `sha1` (string)   
  Validate signature.    
* `sha256` (string)   
  Validate signature.   
* `source` (string)   
  Alias of option "target".   
* `target` (string)   
  File storing the content to assert.   

## Callback parameters

* `err` (Error)   
  Error if assertion failed.   

## Example

```js
nikita.assert({
  ssh: connection
  source: '/tmp/a_file'     
  content: 'nikita is around' 
}, function(err){
  console.log(err);
});
```

## Source code

    module.exports = (options) ->
      options.log message: "Entering file.assert", level: 'DEBUG', module: 'nikita/lib/file/assert'
      # SSH connection
      ssh = @ssh options.ssh
      # Options
      options.encoding ?= 'utf8'
      options.target ?= options.argument
      options.target ?= options.source
      options.filetype ?= []
      options.filetype = [options.filetype] unless Array.isArray options.filetype
      options.filetype = for filetype in options.filetype
        continue unless filetype
        if typeof filetype is 'string'
          switch filetype.toLowerCase()
            when 'ifreg', 'file' then fs.constants.S_IFREG
            when 'ifdir', 'directory' then fs.constants.S_IFDIR
            when 'ifchr', 'chardevice' then fs.constants.S_IFCHR
            when 'iffblk', 'blockdevice' then fs.constants.S_IFBLK
            when 'ififo', 'fifo' then fs.constants.S_IFIFO
            when 'iflink', 'symlink' then fs.constants.S_IFLNK
            when 'ifsock', 'socket' then fs.constants.S_IFSOCK
            else filetype
        else filetype
      options.mode ?= []
      options.mode = [options.mode] unless Array.isArray options.mode
      throw Error 'Missing option: "target"' unless options.target
      if typeof options.content is 'string'
        options.content = Buffer.from options.content, options.encoding
      else if options.content? and not Buffer.isBuffer(options.content) and not options.content instanceof RegExp
        throw Error "Invalid option 'content': expect string, buffer or regexp"
      # Assert file exists
      @call
        unless: options.content? or options.md5 or options.sha1 or options.sha256 or options.mode.length
      , (_, callback) ->
        fs.exists ssh, options.target.toString(), (err, exists) ->
          unless options.not
            unless exists
              options.error ?= "File does not exists: #{JSON.stringify options.target}"
              err = Error options.error
          else
            if exists
              options.error ?= "File exists: #{JSON.stringify options.target}"
              err = Error options.error
          callback err
      # Assert file filetype
      @call
        if: options.filetype.length
      , (_, callback) ->
        fs.lstat ssh, options.target, (err, stat) ->
          return callback err if err
          if fs.constants.S_IFREG in options.filetype
            return callback Error "Invalid filetype: expect a regular file" unless stat.isFile()
          else if fs.constants.S_IFDIR in options.filetype
            return callback Error "Invalid filetype: expect a directory" unless stat.isDirectory()
          else if fs.constants.S_IFCHR in options.filetype
            return callback Error "Invalid filetype: expect a character-oriented device file" unless stat.isCharacterDevice()
          else if fs.constants.S_IFBLK in options.filetype
            return callback Error "Invalid filetype: expect a block-oriented device file" unless stat.isBlockDevice()
          else if fs.constants.S_IFIFO in options.filetype
            return callback Error "Invalid filetype: expect a FIFO/pipe" unless stat.isFIFO()
          else if fs.constants.S_IFLNK in options.filetype
            return callback Error "Invalid filetype: expect a symbolic link" unless stat.isSymbolicLink()
          else if fs.constants.S_IFSOCK in options.filetype
            return callback Error "Invalid filetype: expect a socket" unless stat.isSocket()
          else
            return callback Error "Invalid filetype: #{options.filetype.join ' '}"
          callback()
      # Assert content equal
      @call
        if: options.content? and (typeof options.content is 'string' or Buffer.isBuffer options.content)
      , (_, callback) ->
        fs.readFile ssh, options.target, (err, buffer) ->
          return callback err if err
          unless options.not
            unless buffer.equals options.content
              options.error ?= "Invalid content: expect #{JSON.stringify options.content.toString()} and got #{JSON.stringify buffer.toString()}"
              err = Error options.error
          else
            if buffer.equals options.content
              options.error ?= "Unexpected content: #{JSON.stringify options.content.toString()}"
              err = Error options.error
          callback err
      # Assert content match
      @call
        if: options.content? and options.content instanceof RegExp
      , (_, callback) ->
        fs.readFile ssh, options.target, (err, buffer) ->
          return callback err if err
          unless options.not
            unless options.content.test buffer 
              options.error ?= "Invalid content match: expect #{JSON.stringify options.content.toString()} and got #{JSON.stringify buffer.toString()}"
              err = Error options.error
          else
            if options.content.test buffer
              options.error ?= "Unexpected content match: #{JSON.stringify options.content.toString()}"
              err = Error options.error
          callback err
      # Assert hash match
      (algo = 'md5'; hash = options.md5) if options.md5
      (algo = 'sha1'; hash = options.sha1) if options.sha1
      (algo = 'sha256'; hash = options.sha256) if options.sha256
      @call
        if: algo
      , (_, callback) ->
        file.hash ssh, options.target, algo, (err, h) =>
          return callback Error "Target does not exists: #{options.target}" if err?.code is 'ENOENT'
          return callback err if err
          unless options.not
            if hash isnt h
              options.error ?= "Invalid #{algo} signature: expect #{JSON.stringify hash} and got #{JSON.stringify h}"
              err = Error options.error
          else
            if hash is h
              options.error ?= "Matching #{algo} signature: #{JSON.stringify hash}"
              err = Error options.error
          callback err
      # Assert uid ownerships
      @call
        if: options.uid
      , (_, callback) ->
        fs.stat ssh, options.target, (err, stat) ->
          return callback Error "Target does not exists: #{options.target}" if err?.code is 'ENOENT'
          unless options.not
            unless "#{stat.uid}" is "#{options.uid}"
              options.error ?= "Unexpected uid: expected \"#{options.uid}\" and got \"#{stat.uid}\""
              err = Error options.error
          else
            if "#{stat.uid}" is "#{options.uid}"
              options.error ?= "Unexpected matching uid: expected \"#{options.uid}\""
              err = Error options.error
          callback err
      # Assert gid ownerships
      @call
        if: options.gid
      , (_, callback) ->
        fs.stat ssh, options.target, (err, stat) ->
          return callback Error "Target does not exists: #{options.target}" if err?.code is 'ENOENT'
          unless options.not
            unless "#{stat.gid}" is "#{options.gid}"
              options.error ?= "Unexpected gid: expected \"#{options.gid}\" and got \"#{stat.gid}\""
              err = Error options.error
          else
            if "#{stat.gid}" is "#{options.gid}"
              options.error ?= "Unexpected matching gid: expected \"#{options.gid}\""
              err = Error options.error
          callback err
      # Assert file permissions
      @call
        if: options.mode.length
      , (_, callback) ->
        fs.stat ssh, options.target, (err, stat) ->
          return callback Error "Target does not exists: #{options.target}" if err?.code is 'ENOENT'
          unless options.not
            unless misc.mode.compare options.mode, stat.mode
              expect = options.mode.map (mode) -> "#{pad 4, misc.mode.stringify(mode), '0'}"
              options.error ?= "Invalid mode: expect #{expect} and got #{misc.mode.stringify(stat.mode).substr -4}"
              err = Error options.error
          else
            if misc.mode.compare options.mode, stat.mode
              expect = options.mode.map (mode) -> "#{pad 4, misc.mode.stringify(mode), '0'}"
              options.error ?= "Unexpected valid mode: #{expect}"
              err = Error options.error
          callback err

## Dependencies

    pad = require 'pad'
    fs = require 'ssh2-fs'
    file = require '../misc/file'
    misc = require '../misc'
