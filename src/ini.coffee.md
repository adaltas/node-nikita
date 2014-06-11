
`ini([goptions], options, callback`
-----------------------------------

Write an object as .ini file. Note, we are internally using the
[ini](https://github.com/isaacs/ini) module. However, there is
a subtile difference. Any key provided with value of `undefined`
or `null` will be disregarded. Within a `merge`, it get more prowerfull
and tricky: the original value will be kept if `undefined` is provided
while the value will be removed if `null` is provided.

The `ini` function rely on the `write` function and accept all of its
options. It introduces the `merge` option which instruct to read the
destination file if it exists and merge its parsed object with the one
provided in the `content` option.

    fs = require 'ssh2-fs'
    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    write = require './write'

`options`           Command options include:
*   `append`        Append the content to the destination file. If destination does not exist, the file will be created. When used with the `match` and `replace` options, it will append the `replace` value at the end of the file if no match if found and if the value is a string.
*   `backup`        Create a backup, append a provided string to the filename extension or a timestamp if value is not a string.
*   `content`       Object to stringify.
*   `destination`   File path where to write content to or a callback.
*   `from`          Replace from after this marker, a string or a regular expression.
*   `local_source`  Treat the source as local instead of remote, only apply with "ssh" option.
*   `match`         Replace this marker, a string or a regular expression.
*   `merge`         Read the destination if it exists and merge its content.
*   `replace`       The content to be inserted, used conjointly with the from, to or match options.
*   `source`        File path from where to extract the content, do not use conjointly with content.
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.
*   `parse`         User-defined function to parse the content from ini format, default to `require('ini').parse`, see 'misc.ini.parse_multi_brackets'.
*   `stringify`     User-defined function to stringify the content to ini format, default to `require('ini').stringify`, see 'misc.ini.stringify_square_then_curly' for an example.
*   `separator`     Default separator between keys and values, default to " : ".
*   `to`            Replace to before this marker, a string or a regular expression.
*   `clean`         Remove all the lines whithout a key and a value

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      clean = (content, undefinedOnly) ->
        for k, v of content
          if v and typeof v is 'object'
            content[k] = clean v, undefinedOnly
            continue
          delete content[k] if typeof v is 'undefined'
          delete content[k] if not undefinedOnly and v is null
        content
      result = child()
      finish = (err, written) ->
        callback err, written if callback
        result.end err, written
      misc.options options, (err, options) ->
        return finish err if err
        written = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          {merge, destination, content, ssh} = options
          # Validate parameters
          return next new Error 'Missing content' unless content
          return next new Error 'Missing destination' unless destination
          # Start real work
          do_get = ->
            return do_write() unless merge
            fs.exists ssh, destination, (err, exists) ->
              return next err if err
              return do_write() unless exists
              fs.readFile ssh, destination, 'ascii', (err, c) ->
                return next err if err and err.code isnt 'ENOENT'
                content = clean content, true
                parse = options.parse or misc.ini.parse
                content = misc.merge parse(c, options), content
                do_write()
          do_write = ->
            clean content #if options.clean
            stringify = options.stringify or misc.ini.stringify
            options.content = stringify content, options
            write options, (err, w) ->
              written += w
              next err
          do_get()
        .on 'both', (err) ->
          finish err, written
      result