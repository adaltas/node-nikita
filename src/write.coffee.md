
# `write([goptions], options, callback)`

Write a file or a portion of an existing file.

## Options

*   `append`   
    Append the content to the destination file. If destination does not exist,
    the file will be created.
*   `backup`   
    Create a backup, append a provided string to the filename extension or a
    timestamp if value is not a string.
*   `content`   
    Text to be written, an alternative to source which reference a file.
*   `destination`   
    File path where to write content to.
*   `diff`   
    Print diff information, pass the result of [jsdiff.diffLines][diffLines] as
    argument if a function, default to true.
*   `eof`   
    Ensure the file ends with this charactere sequence, special values are
    'windows', 'mac', 'unix' and 'unicode' (respectively "\r\n", "\r", "\n",
    "\u2028"), will be auto-detected if "true", default to false or "\n" if
    "true" and not detected.
*   `from`   
    Replace from after this marker, a string or a regular expression.
*   `gid`   
    File group name or group id.
*   `local_source`   
    Treat the source as local instead of remote, only apply with "ssh" option.
*   `match`   
    Replace this marker, a string or a regular expression, default to the
    replaced string if missing.
*   `mode`   
    File mode (permission and sticky bits), default to `0666`, in the form of
    `{mode: 0o0744}` or `{mode: "0744"}`.
*   `replace`   
    The content to be inserted, used conjointly with the from, to or match
    options.
*   `source`   
    File path from where to extract the content, do not use conjointly with
    content.
*   `ssh`   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.
*   `stdout`   
    Writable Stream in which diff information are written.
*   `to`   
    Replace to before this marker, a string or a regular expression.
*   `uid`   
    File user name or user id.
*   `write`   
    An array containing multiple transformation where a transformation is an
    object accepting the options `from`, `to`, `match` and `replace`.

## Callback parameters

*   `err`   
    Error object if any.
*   `written`   
    Number of written files.

## More about the `append` option

The `append` option allows more advance usages. If `append` is "null", it will
add the value of the "replace" option at the end of the file when no match
is found and when the value is a string.

Using the `append` option conjointly with the `match` and `replace` options gets
even more interesting. If append is a string or a regular expression, it will
place the value of the "replace" option just after the match. Internally, a
string value will be converted to a regular expression. For example the string
"test" will end up converted to the regular expression `/test/mg`.

## Replacing part of a file using from and to markers

```coffee
mecano.write
  content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
  from: '# from\n'
  to: '# to'
  replace: 'my friend\n'
  destination: "#{scratch}/a_file"
, (err, written) ->
  # here we are\n# from\nmy friend\n# to\nyou coquin
```

## Replacing a matched line by a string

```coffee
mecano.write
  content: 'email=david(at)adaltas(dot)com\nusername=root'
  match: /(username)=(.*)/
  replace: '$1=david (was $2)'
  destination: "#{scratch}/a_file"
, (err, written) ->
  # email=david(at)adaltas(dot)com\nusername=david (was root)
```

## Replacing part of a file using a regular expression

```coffee
mecano.write
  content: 'here we are\nlets try to replace that one\nyou coquin'
  match: /(.*try) (.*)/
  replace: ['my friend, $1']
  destination: "#{scratch}/a_file"
, (err, written) ->
  # here we are\nmy friend, lets try\nyou coquin
```

## Replacing with the global and multiple lines options

```coffee
mecano.write
  content: '#A config file\n#property=30\nproperty=10\n#End of Config'
  match: /^property=.*$/mg
  replace: 'property=50'
  destination: "#{scratch}/replace"
, (err, written) ->
  '# A config file\n#property=30\nproperty=50\n#End of Config'
```

## Appending a line after each line containing "property"

```coffee
mecano.write
  content: '#A config file\n#property=30\nproperty=10\n#End of Config'
  match: /^.*comment.*$/mg
  replace: '# comment'
  destination: "#{scratch}/replace"
  append: 'property'
, (err, written) ->
  '# A config file\n#property=30\n# comment\nproperty=50\n# comment\n#End of Config'
```

## Multiple transformations

```coffee
mecano.write
  content: 'username: me\nemail: my@email\nfriends: you'
  write: [
    match: /^(username).*$/mg
    replace: "$1: you"
  ,
    match: /^email.*$/mg
    replace: ""
  ,
    match: /^(friends).*$/mg
    replace: "$1: me"
  ]
  destination: "#{scratch}/file"
, (err, written) ->
  # username: you\n\nfriends: me
```

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments, parallel: 1
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
          options.log? "Mecano `write`"
          modified = false
          # Validate parameters
          return next new Error 'Missing source or content' unless (options.source or options.content?) or options.replace or options.write?.length
          return next new Error 'Define either source or content' if options.source and options.content
          return next new Error 'Missing destination' unless options.destination
          options.content = options.content.toString() if options.content and Buffer.isBuffer options.content
          options.diff ?= options.diff or !!options.stdout
          switch options.eof
            when 'unix'
              options.eof = "\n"
            when 'mac'
              options.eof = "\r"
            when 'windows'
              options.eof = "\r\n"
            when 'unicode'
              options.eof = "\u2028"
          destination  = null
          destinationHash = null
          content = null
          from = to = between = null
          append = options.append
          write = options.write
          write ?= []
          if options.from? or options.to? or options.match? or options.replace?
            write.push
              from: options.from
              to: options.to
              match: options.match
              replace: options.replace
              append: options.append
          for w in write
            if not w.from? and not w.to? and not w.match? and w.replace?
              w.match = w.replace
          # Start work
          do_read_source = ->
            if options.content?
              content = options.content
              content = "#{content}" if typeof content is 'number'
              return do_read_destination()
            # Option "local_source" force to bypass the ssh
            # connection, use by the upload function
            source = options.source or options.destination
            options.log? "Mecano `write`: force local source is \"#{if options.local_source then 'true' else 'false'}\""
            options.log? "Mecano `write`: source is \"#{options.source}\""
            ssh = if options.local_source then null else options.ssh
            fs.exists ssh, source, (err, exists) ->
              return next err if err
              unless exists
                return next new Error "Source does not exist: #{JSON.stringify options.source}" if options.source
                content = ''
                return do_read_destination()
              options.log? "Mecano `write`: read source"
              fs.readFile ssh, source, 'utf8', (err, src) ->
                return next err if err
                content = src
                do_read_destination()
          do_read_destination = ->
            # no need to test changes if destination is a callback
            return do_render() if typeof options.destination is 'function'
            options.log? "Mecano `write`: destination is \"#{options.destination}\""
            exists = ->
              options.log? "Mecano `write`: stat destination"
              fs.stat options.ssh, options.destination, (err, stat) ->
                return do_mkdir() if err?.code is 'ENOENT'
                return next err if err
                if stat.isDirectory()
                  options.destination = "#{options.destination}/#{path.basename options.source}"
                  # Destination is the parent directory, let's see if the file exist inside
                  fs.stat options.ssh, options.destination, (err, stat) ->
                    # File doesnt exist
                    return do_render() if err?.code is 'ENOENT'
                    return next err if err
                    return next new Error "Destination is not a file: #{options.destination}" unless stat.isFile()
                    do_read()
                else
                  do_read()
            do_mkdir = ->
              options.log? "Mecano `write`: mkdir"
              mkdir
                ssh: options.ssh
                destination: path.dirname options.destination
                uid: options.uid
                gid: options.gid
                mode: options.mode
                # We only apply uid and gid if the dir does not yet exists
                not_if_exists: path.dirname options.destination
              , (err, created) ->
                return next err if err
                do_render()
            do_read = ->
              options.log? "Mecano `write`: read destination"
              fs.readFile options.ssh, options.destination, 'utf8', (err, dest) ->
                return next err if err
                destination = dest if options.diff # destination content only use by diff
                destinationHash = misc.string.hash dest
                do_render()
            exists()
          do_render = ->
            return do_replace_partial() unless options.context?
            options.log? "Mecano `write`: rendering with eco"
            try
              content = eco.render content.toString(), options.context
              if options.skip_empty_lines?
                content = content.replace(/(\r\n|[\n\r\u0085\u2028\u2029])\s*(\r\n|[\n\r\u0085\u2028\u2029])/g, "$1")
            catch err
              err = new Error err if typeof err is 'string'
              return next err
            do_replace_partial()
          do_replace_partial = ->
            return do_eof() unless write.length
            options.log? "Mecano `write`: replace"
            for opts in write
              if opts.match
                if typeof opts.match is 'string'
                  opts.match = RegExp quote(opts.match), 'mg'
                if opts.match instanceof RegExp
                  if opts.match.test content
                    content = content.replace opts.match, opts.replace
                    append = false
                  else if opts.append and typeof opts.replace is 'string'
                    if typeof opts.append is "string"
                      opts.append = new RegExp "^.*#{opts.append}.*$", 'mg'
                    if opts.append instanceof RegExp
                      posoffset = 0
                      orgContent = content
                      while (res = opts.append.exec orgContent) isnt null
                        pos = posoffset + res.index + res[0].length
                        content = content.slice(0,pos) + '\n'+opts.replace + content.slice(pos)
                        posoffset += opts.replace.length + 1
                        break unless opts.append.global
                      append = false
                    else
                      linebreak = if content.length is 0 or content.substr(content.length - 1) is '\n' then '' else '\n'
                      content = content + linebreak + opts.replace
                      append = false
                  else
                    # Did not match, try next one
                    continue
                else
                  return next new Error "Invalid match option"
                  # from = content.indexOf(opts.match)
                  # to = from + opts.match.length
                  # content = content.substr(0, from) + opts.replace + content.substr(to)
              else
                from = if opts.from then content.indexOf(opts.from) + opts.from.length else 0
                to = if opts.to then content.indexOf(opts.to) else content.length
                content = content.substr(0, from) + opts.replace + content.substr(to)
            do_eof()
          do_eof = ->
            return do_diff() unless options.eof?
            options.log? "Mecano `write`: add eof"
            if options.eof is true
              for char, i in content
                if char is '\r'
                  options.eof = if content[i+1] is '\n' then '\r\n' else char
                  break
                if char is '\n' or char is '\u2028'
                  options.eof = char
                  break;
              options.eof = '\n' if options.eof is true
            content += options.eof unless misc.string.endsWith content, options.eof
            do_diff()
          do_diff = ->
            return do_ownership() if destinationHash is misc.string.hash content
            options.log? "Mecano `write`: file content has changed"
            if options.diff
              lines = diff.diffLines destination, content
              options.diff lines if typeof options.diff is 'function'
              if options.stdout
                count_added = count_removed = 0
                padsize = Math.ceil(lines.length/10)
                for line in lines
                  continue if line.value is null
                  if not line.added and not line.removed
                    count_added++; count_removed++; continue
                  ls = line.value.split(/\r\n|[\n\r\u0085\u2028\u2029]/g)
                  if line.added
                    for line in ls
                      count_added++
                      options.stdout.write "#{pad padsize, ''+(count_added)} + #{line}\n"
                  else
                    for line in ls
                      count_removed++
                      options.stdout.write "#{pad padsize, ''+(count_removed)} - #{line}\n"
            do_write()
          do_write = ->
            if typeof options.destination is 'function'
              options.log? "Mecano `write`: write destination with user function"
              options.destination content
              do_end()
            else
              options.log? "Mecano `write`: write destination"
              options.flags ?= 'a' if append
              fs.writeFile options.ssh, options.destination, content, options, (err) ->
                return next err if err
                modified = true
                do_backup()
          do_backup = ->
            return do_end() unless options.backup
            options.log? "Mecano `write`: create backup"
            backup = options.backup
            backup = ".#{Date.now()}" if backup is true
            backup = "#{options.destination}#{backup}"
            fs.writeFile options.ssh, backup, content, (err) ->
              return next err if err
              do_end()
          do_ownership = ->
            return do_permissions() unless options.uid? and options.gid?
            options.log? "Mecano `write`: change ownership"
            chown
              ssh: options.ssh
              destination: options.destination
              uid: options.uid
              gid: options.gid
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, chowned) ->
              return next err if err
              modified = true if chowned
              do_permissions()
          do_permissions = ->
            return do_end() unless options.mode?
            options.log? "Mecano `write`: change permissions"
            chmod
              ssh: options.ssh
              destination: options.destination
              mode: options.mode
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, chmoded) ->
              return next err if err
              modified = true if chmoded
              do_end()
          do_end = ->
            written++ if modified
            next()
          conditions.all options, next, do_read_source
        .on 'both', (err) ->
          finish err, written
      result

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    each = require 'each'
    eco = require 'eco'
    pad = require 'pad'
    diff = require 'diff'
    quote = require 'regexp-quote'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    mkdir = require './mkdir'
    chown = require './chown'
    chmod = require './chmod'





[diffLines]: https://github.com/kpdecker/jsdiff


