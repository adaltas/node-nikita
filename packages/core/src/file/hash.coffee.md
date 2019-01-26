
# `nikita.file.hash`

Retrieve the hash of a file or a directory in hexadecimal 
form.

If the target is a directory, the returned hash 
is the sum of all the hashs of the files it recursively 
contains. The default algorithm to compute the hash is md5.

If the target is a link, the returned hash is of the linked file.

It is possible to use to action to assert the target file by passing a `hash`
used for comparaison.

## Options

* `algo` (string)   
  Any algorythm supported by `openssl`; default to "md5".
* `hash` (string)   
  Expected hash to validate.
* `target` (string)   
  The file or directory to compute the hash from.

## Callback information

* `hash`   
  The hash of the file or directory identified by the "target" option.

    module.exports = shy: true, handler: ({options}, callback) ->
      @log message: "Entering file.hash", level: 'DEBUG', module: 'nikita/lib/file/hash'
      options.algo ?= 'md5'
      options.target = options.argument if options.argument?
      throw Error "Required Option: target, got #{JSON.stringify options.target}" unless options.target
      info = {}
      @fs.stat
        unless: options.stats
        target: options.target
      , (err, {stats}) ->
        throw err if err
        options.stats = stats
        throw Error 'Unsupported file type' unless misc.stats.isFile(stats.mode) or misc.stats.isDirectory(stats.mode)
      # Target is a directory
      @file.glob
        if: -> misc.stats.isDirectory options.stats.mode
        target: "#{options.target}/**"
        dot: true
      , (err, {status, files}) ->
        return unless status
        throw err if err
        @system.execute
          cmd: [
            'which openssl >/dev/null || exit 2'
            ...files.map (file) -> "[ -f #{file} ] && openssl dgst -#{options.algo} #{file} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'"
            'exit 0'
          ].join '\n'
          trim: true
        , (err, {stdout}) ->
          throw Error "Command does not exist: openssl" if err?.code is 2
          throw err if err
          hashs = string.lines(stdout).filter( (line) -> /\w+/.test line ).sort()
          info.hash = if hashs.length is 0
            crypto.createHash(options.algo).update('').digest('hex')
          else if hashs.length is 1
            hashs[0]
          else
            crypto.createHash(options.algo).update(hashs.join('')).digest('hex')
      # Target is a file
      @system.execute
        if: -> misc.stats.isFile options.stats.mode
        cmd: """
        which openssl >/dev/null || exit 2
        openssl dgst -#{options.algo} #{options.target} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'
        """
        trim: true
      , (err, {status, stdout}) ->
        throw Error "Command does not exist: openssl" if err?.code is 2
        throw err if err
        return unless status
        info.hash = stdout
      @call
        if: options.hash
      , ->
        if options.hash isnt stdout
        then throw Error "Unexpected Hash, got #{JSON.stringify stdout} but exepected #{JSON.stringify options.hash}"
      @next (err) ->
        info.status = true unless err
        callback err, info

## Dependencies

    crypto = require 'crypto'
    misc = require '../misc'
    string = require '../misc/string'
