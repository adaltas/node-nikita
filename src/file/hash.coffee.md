
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

    module.exports = shy: false, handler: ({options}, callback) ->
      options.algo ?= 'md5'
      options.target = options.argument if options.argument?
      throw Error "Required Option: target, got #{JSON.stringify options.target}" unless options.target
      @fs.stat
        unless: options.stats
        target: options.target
      , (err, {stats}) ->
        throw err if err
        options.stats = stats
        throw Error 'Unsupported file type' unless misc.stats.isFile stats.mode
      @system.execute
        cmd: """
        which openssl >/dev/null || exit 2
        openssl dgst -#{options.algo} #{options.target} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'
        """
        trim: true
      , (err, {stdout}) ->
        throw Error "Command does not exist: openssl" if err?.code is 2
        if options.hash and options.hash isnt stdout
          throw Error "Unexpected Hash, got #{JSON.stringify stdout} but exepected #{JSON.stringify options.hash}"
        callback err, status: true, hash: stdout
      @next (err) ->
        callback err if err

## Dependencies

    misc = require '../misc'
