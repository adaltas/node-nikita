
# `write(options, callback)`

Write a file or a portion of an existing file.

## Options

*   `append`   
    Append the content to the target file. If target does not exist,
    the file will be created.   
*   `backup`   
    Create a backup, append a provided string to the filename extension or a
    timestamp if value is not a string.   
*   `content`   
    Text to be written, an alternative to source which reference a file.   
*   `target`   
    File path where to write content to.   
*   `diff` (boolean | function)   
    Print diff information, pass a readable diff and the result of [jsdiff.diffLines][diffLines] as
    arguments if a function, default to true.   
*   `eof`   
    Ensure the file ends with this charactere sequence, special values are
    'windows', 'mac', 'unix' and 'unicode' (respectively "\r\n", "\r", "\n",
    "\u2028"), will be auto-detected if "true", default to false or "\n" if
    "true" and not detected.   
*   `from`   
    Replace from after this marker, a string or a regular expression.   
*   `gid`   
    File group name or group id.   
*   `local`   
    Treat the source as local instead of remote, only apply with "ssh"
    option.   
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
*   `to`   
    Replace to before this marker, a string or a regular expression.   
*   `uid`   
    File user name or user id.   
*   `unlink` (boolean)   
    Replace the existing link, leaving the refered file untouched.   
*   `write`   
    An array containing multiple transformation where a transformation is an
    object accepting the options `from`, `to`, `match` and `replace`.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.    

## Callback parameters

*   `err`   
    Error object if any.   
*   `modified`   
    Number of written actions with modifications.   

## Implementation details

Internally, this function uses the "chmod" and "chown" function and, thus,
honor all their options including "mode", "uid" and "gid".   

## Diff Lines

Diff can be obtained when the options "diff" is set to true or a function. The
information is provided in two ways:

*   when `true`, a formated string written to the "stdout" option.   
*   when a function, a readable diff and the array returned by the function 
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
require('mecano').write({
  content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin',
  from: '# from\n',
  to: '# to',
  replace: 'my friend\n',
  target: scratch+'/a_file'
}, function(err, written){
  // '# here we are\n# from\nmy friend\n# to\nyou coquin'
})
```

## Replacing a matched line by a string

```js
require('mecano').write({
  content: 'email=david(at)adaltas(dot)com\nusername=root',
  match: /(username)=(.*)/,
  replace: '$1=david (was $2)',
  target: scratch+'/a_file'
}, function(err, written){
  // '# email=david(at)adaltas(dot)com\nusername=david (was root)'
})
```

## Replacing part of a file using a regular expression

```js
require('mecano').write({
  content: 'here we are\nlets try to replace that one\nyou coquin',
  match: /(.*try) (.*)/,
  replace: ['my friend, $1'],
  target: scratch+'/a_file'
}, function(err, written){
  // '# here we are\nmy friend, lets try\nyou coquin'
})
```

## Replacing with the global and multiple lines options

```js
require('mecano').write({
  content: '#A config file\n#property=30\nproperty=10\n#End of Config',
  match: /^property=.*$/mg,
  replace: 'property=50',
  target: scratch+'/a_file'
}, function(err, written){
  // '# A config file\n#property=30\nproperty=50\n#End of Config'
})
```

## Appending a line after each line containing "property"

```js
require('mecano').write({
  content: '#A config file\n#property=30\nproperty=10\n#End of Config',
  match: /^.*comment.*$/mg,
  replace: '# comment',
  target: scratch+'/a_file',
  append: 'property'
}, function(err, written){
  // '# A config file\n#property=30\n# comment\nproperty=50\n# comment\n#End of Config'
})
```

## Multiple transformations

```js
require('mecano').write({
  content: 'username: me\nemail: my@email\nfriends: you',
  write: [
    {match: /^(username).*$/mg, replace: '$1: you'},
    {match: /^email.*$/mg, replace: ''},
    {match: /^(friends).*$/mg, replace: '$1: me'}
  ],
  target: scratch+'/a_file'
}, function(err, written){
  // 'username: you\n\nfriends: me'
})
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering write", level: 'DEBUG', module: 'mecano/lib/write'
      modified = false
      # Validate parameters
      return callback Error 'Missing source or content' unless (options.source or options.content?) or options.replace or options.write?
      return callback Error 'Define either source or content' if options.source and options.content
      return callback Error 'Missing target' unless options.target
      options.log message: "Source is \"#{options.source}\"", level: 'DEBUG', module: 'mecano/lib/write'
      options.log message: "Destination is \"#{options.target}\"", level: 'DEBUG', module: 'mecano/lib/write'
      options.content = options.content.toString() if options.content and Buffer.isBuffer options.content
      options.diff ?= options.diff or !!options.stdout
      options.engine ?= 'nunjunks'
      options.unlink ?= false
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
      if options.from? or options.to? or options.match? or options.replace? or options.before?
        options.write.push
          from: options.from
          to: options.to
          match: options.match
          replace: options.replace
          append: options.append
          before: options.before
        options.append = false
      for w in options.write
        if not w.from? and not w.to? and not w.match? and w.replace?
          w.match = w.replace
      # Start work
      @call (_, callback) -> # read source
        if options.content?
          options.content = "#{options.content}" if typeof options.content is 'number'
          return callback()
        # Option "local" force to bypass the ssh
        # connection, use by the upload function
        source = options.source or options.target
        options.log message: "Force local source is \"#{if options.local then 'true' else 'false'}\"", level: 'DEBUG', module: 'mecano/lib/write'
        ssh = if options.local then null else options.ssh
        fs.exists ssh, source, (err, exists) ->
          return callback err if err
          unless exists
            return callback new Error "Source does not exist: #{JSON.stringify options.source}" if options.source
            options.content = ''
            return callback()
          options.log message: "Reading source", level: 'DEBUG', module: 'mecano/lib/write'
          fs.readFile ssh, source, 'utf8', (err, src) ->
            return callback err if err
            options.content = src
            callback()
      targetStat = null
      @call (_, callback) -> # read target
        # no need to test changes if target is a callback
        return callback() if typeof options.target is 'function'
        exists = ->
          options.log message: "Stat target", level: 'DEBUG', module: 'mecano/lib/write'
          fs.lstat options.ssh, options.target, (err, stat) ->
            return do_mkdir() if err?.code is 'ENOENT'
            return callback err if err
            targetStat = stat
            if stat.isDirectory()
              options.target = "#{options.target}/#{path.basename options.source}"
              options.log message: "Destination is a directory and is now \"options.target\"", level: 'INFO', module: 'mecano/lib/write'
              # Destination is the parent directory, let's see if the file exist inside
              fs.stat options.ssh, options.target, (err, stat) ->
                if err?.code is 'ENOENT'
                  options.log message: "New target does not exist", level: 'INFO', module: 'mecano/lib/write'
                  return callback()
                return callback err if err
                return callback new Error "Destination is not a file: #{options.target}" unless stat.isFile()
                options.log message: "New target exist", level: 'INFO', module: 'mecano/lib/write'
                targetStat = stat
                do_read()
            else if stat.isSymbolicLink()
              options.log message: "Destination is a symlink", level: 'INFO', module: 'mecano/lib/write'
              return do_read() unless options.unlink
              fs.unlink options.ssh, options.target, (err, stat) ->
                return callback err if err
                callback() # Dont go to mkdir since parent dir exists
            else if stat.isFile()
              options.log message: "Destination is a file", level: 'INFO', module: 'mecano/lib/write'
              do_read()
            else
              callback Error "Invalid File Type Destination"
        do_mkdir = =>
          @mkdir
            target: path.dirname options.target
            uid: options.uid
            gid: options.gid
            mode: options.mode
            # Modify uid and gid if the dir does not yet exists
            unless_exists: path.dirname options.target
          , (err, created) ->
            return callback err if err
            callback()
        do_read = ->
          options.log message: "Reading target", level: 'DEBUG', module: 'mecano/lib/write'
          fs.readFile options.ssh, options.target, 'utf8', (err, dest) ->
            return callback err if err
            target = dest # only used by diff
            targetHash = string.hash dest
            callback()
        exists()
      @call  -> # render
        string.render options if options.context?
      @call -> # skip_empty_lines
        return unless options.skip_empty_lines?
        options.log message: "Skip empty lines", level: 'DEBUG', module: 'mecano/lib/write'
        options.content = options.content.replace /(\r\n|[\n\r\u0085\u2028\u2029])\s*(\r\n|[\n\r\u0085\u2028\u2029])/g, "$1"
      @call -> # replace_partial
        string.replace_partial options if options.write.length
      @call -> # eof
        return unless options.eof?
        options.log message: "Checking option eof", level: 'DEBUG', module: 'mecano/lib/write'
        if options.eof is true
          for char, i in options.content
            if char is '\r'
              options.eof = if options.content[i+1] is '\n' then '\r\n' else char
              break
            if char is '\n' or char is '\u2028'
              options.eof = char
              break;
          options.eof = '\n' if options.eof is true
          options.log message: "Option eof is true, gessing as #{JSON.stringify options.eof}", level: 'INFO', module: 'mecano/lib/write'
        unless string.endsWith options.content, options.eof
          options.log message: "Add eof", level: 'WARN', module: 'mecano/lib/write'
          options.content += options.eof
      @call (_, callback) -> # diff
        return callback() if targetHash is string.hash options.content
        options.log message: "File content has changed: #{options.target}", level: 'WARN', module: 'mecano/lib/write'
        {raw, text} = diff target, options.content, options
        options.diff text, raw if typeof options.diff is 'function'
        options.log message: text, type: 'diff', level: 'INFO', module: 'mecano/lib/write'
        callback null, true
      @call -> # backup
        return unless @status()
        return unless options.backup and targetHash
        options.log message: "Create backup", level: 'INFO', module: 'mecano/lib/write'
        backup = if typeof options.backup is 'string' then options.backup else ".#{Date.now()}"
        @copy
          ssh: options.ssh
          source: options.target
          target: "#{options.target}#{backup}"
      @call (_, callback) -> # write
        return callback() unless @status()
        if typeof options.target is 'function'
          options.log message: "Write target with user function", level: 'INFO', module: 'mecano/lib/write'
          options.target options.content
          return callback()
        options.log message: "Write target", level: 'INFO', module: 'mecano/lib/write'
        options.flags ?= 'a' if options.append
        # Ownership and permission are also handled
        uid_gid options, (err) ->
          return callback err if err
          fs.writeFile options.ssh, options.target, options.content, options, (err) ->
            return callback err if err
            options.log message: "File written", level: 'INFO', module: 'mecano/lib/write'
            modified = true
            callback()
      @chown
        target: options.target
        stat: targetStat
        uid: options.uid
        gid: options.gid
        if: options.uid? or options.gid?
        unless: options.target is 'function'
      @chmod
        target: options.target
        stat: targetStat
        mode: options.mode
        if: options.mode?
        unless: options.target is 'function'
      @then callback

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    eco = require 'eco'
    nunjucks = require 'nunjucks/src/environment'
    misc = require '../misc'
    diff = require '../misc/diff'
    string = require '../misc/string'
    uid_gid = require '../misc/uid_gid'

[diffLines]: https://github.com/kpdecker/jsdiff
