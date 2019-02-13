
# `nikita.file`

Write a file or a portion of an existing file.

## Options

* `append`   
  Append the content to the target file. If target does not exist,
  the file will be created.
* `backup` (string|boolean)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `backup_mode`   
  Backup file mode (permission and sticky bits), defaults to `0o0400`, in the 
  form of `{mode: 0o0400}` or `{mode: "0400"}`.
* `content`   
  Text to be written, an alternative to source which reference a file.
* `diff` (boolean | function)   
  Print diff information, pass a readable diff and the result of [jsdiff.diffLines][diffLines] as
  arguments if a function, default to true.
* `eof`   
  Ensure the file ends with this charactere sequence, special values are
  'windows', 'mac', 'unix' and 'unicode' (respectively "\r\n", "\r", "\n",
  "\u2028"), will be auto-detected if "true", default to false or "\n" if
  "true" and not detected.
* `from`   
  Replace from after this marker, a string or a regular expression.
* `gid`   
  File group name or group id.
* `local`   
  Treat the source as local instead of remote, only apply with "ssh"
  option.
* `match`   
  Replace this marker, a string or a regular expression, default to the
  replaced string if missing.
* `mode`   
  File mode (permission and sticky bits), default to `0o0644`, in the form of
  `{mode: 0o0744}` or `{mode: "0744"}`.
* `place_before` (string, boolean, regex)   
  Place the content before the match.
* `replace`   
  The content to be inserted, used conjointly with the from, to or match
  options.
* `source`   
  File path from where to extract the content, do not use conjointly with
  content.
* `target`   
  File path where to write content to.
* `to`   
  Replace to before this marker, a string or a regular expression.
* `uid`   
  File user name or user id.
* `unlink` (boolean)   
  Replace the existing link, leaving the refered file untouched.
* `write`   
  An array containing multiple transformation where a transformation is an
  object accepting the options `from`, `to`, `match` and `replace`.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  Indicate file modifications.

## Implementation details

Internally, this function uses the "chmod" and "chown" function and, thus,
honor all their options including "mode", "uid" and "gid".

## Diff Lines

Diff can be obtained when the options "diff" is set to true or a function. The
information is provided in two ways:

* when `true`, a formated string written to the "stdout" option.
* when a function, a readable diff and the array returned by the function 
  `diff.diffLines`, see the [diffLines] package for additionnal information.

## More about the `append` option

The `append` option allows more advanced usages. If `append` is "null", it will
add the value of the "replace" option at the end of the file when no match
is found and when the value is a string.

Using the `append` option conjointly with the `match` and `replace` options gets
even more interesting. If append is a string or a regular expression, it will
place the value of the "replace" option just after the match. Internally, a
string value will be converted to a regular expression. For example the string
"test" will end up converted to the regular expression `/test/mg`.

## Replacing part of a file using from and to markers

```js
require('nikita')
.file({
  content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin',
  from: '# from\n',
  to: '# to',
  replace: 'my friend\n',
  target: scratch+'/a_file'
}, function(err, {status}){
  // '# here we are\n# from\nmy friend\n# to\nyou coquin'
})
```

## Replacing a matched line by a string

```js
require('nikita')
.file({
  content: 'email=david(at)adaltas(dot)com\nusername=root',
  match: /(username)=(.*)/,
  replace: '$1=david (was $2)',
  target: scratch+'/a_file'
}, function(err, {status}){
  // '# email=david(at)adaltas(dot)com\nusername=david (was root)'
})
```

## Replacing part of a file using a regular expression

```js
require('nikita')
.file({
  content: 'here we are\nlets try to replace that one\nyou coquin',
  match: /(.*try) (.*)/,
  replace: ['my friend, $1'],
  target: scratch+'/a_file'
}, function(err, {status}){
  // '# here we are\nmy friend, lets try\nyou coquin'
})
```

## Replacing with the global and multiple lines options

```js
require('nikita')
.file({
  content: '#A config file\n#property=30\nproperty=10\n#End of Config',
  match: /^property=.*$/mg,
  replace: 'property=50',
  target: scratch+'/a_file'
}, function(err, {status}){
  // '# A config file\n#property=30\nproperty=50\n#End of Config'
})
```

## Appending a line after each line containing "property"

```js
require('nikita')
.file({
  content: '#A config file\n#property=30\nproperty=10\n#End of Config',
  match: /^.*comment.*$/mg,
  replace: '# comment',
  target: scratch+'/a_file',
  append: 'property'
}, function(err, {status}){
  // '# A config file\n#property=30\n# comment\nproperty=50\n# comment\n#End of Config'
})
```

## Multiple transformations

```js
require('nikita')
.file({
  content: 'username: me\nemail: my@email\nfriends: you',
  write: [
    {match: /^(username).*$/mg, replace: '$1: you'},
    {match: /^email.*$/mg, replace: ''},
    {match: /^(friends).*$/mg, replace: '$1: me'}
  ],
  target: scratch+'/a_file'
}, function(err, {status}){
  // 'username: you\n\nfriends: me'
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering file", level: 'DEBUG', module: 'nikita/lib/file'
      # SSH connection
      ssh = @ssh options.ssh
      # Content: pass all arguments to function calls
      context = arguments[0]
      # Validate parameters
      return throw Error 'Missing source or content' unless (options.source or options.content?) or options.replace or options.write?
      return throw Error 'Define either source or content' if options.source and options.content
      return throw Error 'Missing target' unless options.target
      @log message: "Source is \"#{options.source}\"", level: 'DEBUG', module: 'nikita/lib/file'
      @log message: "Destination is \"#{options.target}\"", level: 'DEBUG', module: 'nikita/lib/file'
      options.content = options.content.toString() if options.content and Buffer.isBuffer options.content
      options.content = options.content.call @, context if typeof options.content is 'function'
      options.diff ?= options.diff or !!options.stdout
      options.engine ?= 'nunjunks'
      options.unlink ?= false
      options.encoding ?= 'utf8'
      switch options.eof
        when 'unix'
          options.eof = "\n"
        when 'mac'
          options.eof = "\r"
        when 'windows'
          options.eof = "\r\n"
        when 'unicode'
          options.eof = "\u2028"
      target  = null
      targetHash = null
      options.write ?= []
      if options.from? or options.to? or options.match? or options.replace? or options.place_before?
        options.write.push
          from: options.from
          to: options.to
          match: options.match
          replace: options.replace
          append: options.append
          place_before: options.place_before
        options.append = false
      for w in options.write
        if not w.from? and not w.to? and not w.match? and w.replace?
          w.match = w.replace
      # Start work
      @call ({}, callback) -> # read source
        if options.content?
          options.content = "#{options.content}" if typeof options.content is 'number'
          return callback()
        # Option "local" force to bypass the ssh
        # connection, use by the upload function
        source = options.source or options.target
        @log message: "Force local source is \"#{if options.local then 'true' else 'false'}\"", level: 'DEBUG', module: 'nikita/lib/file'
        @fs.exists
          ssh: if options.local then false else options.ssh
          target: source
        , (err, {exists}) ->
          return callback err if err
          unless exists
            return callback Error "Source does not exist: #{JSON.stringify options.source}" if options.source
            options.content = ''
            return callback()
          @log message: "Reading source", level: 'DEBUG', module: 'nikita/lib/file'
          @fs.readFile
            ssh: if options.local then false else options.ssh
            target: source
            encoding: options.encoding
          , (err, {data}) ->
            return callback err if err
            options.content = data
            callback()
      targetStats = null
      @call ({}, callback) -> # read target
        # no need to test changes if target is a callback
        return callback() if typeof options.target is 'function'
        exists = =>
          @log message: "Stat target", level: 'DEBUG', module: 'nikita/lib/file'
          @fs.lstat target: options.target, relax: true, (err, {stats}) ->
            return do_mkdir() if err?.code is 'ENOENT'
            return callback err if err
            targetStats = stats
            if misc.stats.isDirectory stats
              options.target = "#{options.target}/#{path.basename options.source}"
              @log message: "Destination is a directory and is now \"options.target\"", level: 'INFO', module: 'nikita/lib/file'
              # Destination is the parent directory, let's see if the file exist inside
              @fs.stat target: options.target, (err, {stats}) ->
                if err?.code is 'ENOENT'
                  @log message: "New target does not exist", level: 'INFO', module: 'nikita/lib/file'
                  return callback()
                return callback err if err
                return callback Error "Destination is not a file: #{options.target}" unless misc.stats.isFile stats.mode
                @log message: "New target exist", level: 'INFO', module: 'nikita/lib/file'
                targetStats = stats
                do_read()
            else if misc.stats.isSymbolicLink stats.mode
              @log message: "Destination is a symlink", level: 'INFO', module: 'nikita/lib/file'
              return do_read() unless options.unlink
              @fs.unlink target: options.target, (err) ->
                return callback err if err
                callback() # Dont go to mkdir since parent dir exists
            else if misc.stats.isFile stats.mode
              @log message: "Destination is a file", level: 'INFO', module: 'nikita/lib/file'
              do_read()
            else
              callback Error "Invalid File Type Destination: #{options.target}"
        do_mkdir = =>
          options.mode = parseInt(options.mode, 8) if typeof options.mode is 'string'
          @system.mkdir
            target: path.dirname options.target
            uid: options.uid
            gid: options.gid
            # force execution right on mkdir
            mode: if options.mode then (options.mode | 0o111) else 0o755 
            # Modify uid and gid if the dir does not yet exists
            unless_exists: path.dirname options.target
          , (err, created) ->
            return callback err if err
            callback()
        do_read = =>
          @log message: "Reading target", level: 'DEBUG', module: 'nikita/lib/file'
          @fs.readFile target: options.target, encoding: options.encoding, (err, {data}) ->
            return callback err if err
            target = data # only used by diff
            targetHash = string.hash data
            callback()
        exists()
      @call  -> # render
        string.render.call @, options if options.context?
      @call -> # skip_empty_lines
        return unless options.skip_empty_lines?
        @log message: "Skip empty lines", level: 'DEBUG', module: 'nikita/lib/file'
        options.content = options.content.replace /(\r\n|[\n\r\u0085\u2028\u2029])\s*(\r\n|[\n\r\u0085\u2028\u2029])/g, "$1"
      @call -> # replace_partial
        string.replace_partial.call @, options if options.write.length
      @call -> # eof
        return unless options.eof?
        @log message: 'Checking option eof', level: 'DEBUG', module: 'nikita/lib/file'
        if options.eof is true
          for char, i in options.content
            if char is '\r'
              options.eof = if options.content[i+1] is '\n' then '\r\n' else char
              break
            if char is '\n' or char is '\u2028'
              options.eof = char
              break;
          options.eof = '\n' if options.eof is true
          @log message: "Option eof is true, guessing as #{JSON.stringify options.eof}", level: 'INFO', module: 'nikita/lib/file'
        unless string.endsWith options.content, options.eof
          @log message: 'Add eof', level: 'INFO', module: 'nikita/lib/file'
          options.content += options.eof
      @call ({}, callback) -> # diff
        return callback() if targetHash is string.hash options.content
        @log message: "File content has changed: #{options.target}", level: 'WARN', module: 'nikita/lib/file'
        {raw, text} = diff target, options.content, options
        options.diff text, raw if typeof options.diff is 'function'
        @log message: text, type: 'diff', level: 'INFO', module: 'nikita/lib/file'
        callback null, true
      @call -> # backup
        return unless @status()
        return unless options.backup and targetHash
        @log message: "Create backup", level: 'INFO', module: 'nikita/lib/file'
        options.backup_mode ?= 0o0400
        backup = if typeof options.backup is 'string' then options.backup else ".#{Date.now()}"
        @system.copy
          source: options.target
          target: "#{options.target}#{backup}"
          mode: options.backup_mode
      @call ({}, callback) -> # file
        return callback() unless @status()
        if typeof options.target is 'function'
          @log message: 'Write target with user function', level: 'INFO', module: 'nikita/lib/file'
          options.target options.content
          return callback()
        options.flags ?= 'a' if options.append
        # Ownership and permission are also handled
        # Preserved the file mode if the file exists. Otherwise,
        # delegate to fs.createWriteStream` the creation of the default
        # mode of "744".
        @fs.writeFile
          target: options.target
          flags: options.flags
          content: options.content
          mode: targetStats?.mode
        , callback
      @system.uid_gid
        uid: options.uid
        gid: options.gid
        shy: true
      , (err, {status, uid, gid, default_gid}) ->
        options.uid = uid
        options.gid = unless targetStats then default_gid else gid
      @call ->
        # Option gid is set at runtime if target is a new file
        @system.chown
          target: options.target
          stats: targetStats
          sudo: options.sudo
          uid: options.uid
          gid: options.gid
          if: options.uid? or options.gid?
          unless: options.target is 'function'
        @system.chmod
          target: options.target
          stats: targetStats
          sudo: options.sudo
          mode: options.mode
          if: options.mode?
          unless: options.target is 'function'

## Dependencies

    path = require 'path'
    nunjucks = require 'nunjucks/src/environment'
    misc = require '../misc'
    diff = require '../misc/diff'
    string = require '../misc/string'

[diffLines]: https://github.com/kpdecker/jsdiff
