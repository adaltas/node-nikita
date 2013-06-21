---
language: en
layout: page
title: "Node Mecano: Common functions for system deployment"
date: 2013-06-21T09:31:04.318Z
comments: false
sharing: false
footer: false
github: https://github.com/wdavidw/node-mecano
---
Mecano gather a set of functions usually used during system deployment. All the functions share a 
common API with flexible options.

Functions include "copy", "download", "exec", "extract", "git", "link", "mkdir", "move", "remove", "render", "service", "write". They all share common usages and philosophies:   
*   Run actions both locally and remotely over SSH.   
*   Ability to see if an action had an effect through the second argument provided in the callback.   
*   Common API with options and callback arguments and calling the callback with an error and the number of affected actions.   
*   Run one or multiple actions depending on option argument being an object or an array of objects.   

`cp` `copy(options, callback)`
------------------------------

Copy a file. The behavior is similar to the one of the `cp` 
Unix utility. Copying a file over an existing file will 
overwrite it.

`options`           Command options include:   

*   `source`        The file or directory to copy.
*   `destination`   Where the file or directory is copied.
*   `not_if_exists` Equals destination if true.
*   `mode`         Permissions of the file or the parent directory
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `copied`        Number of files or parent directories copied.

todo:
*   preserve permissions if `mode` is `true`

`download(options, callback)`
-----------------------------

Download files using various protocols.

When executed locally: the `http` protocol is handled 
with the "request" module; the `ftp` protocol is handled 
with the "jsftp"; the `file` protocol is handle with the navite 
`fs` module.

`options`           Command options include:   

*   `source`        File, HTTP URL, FTP, GIT repository. File is the default protocol if source is provided without any.   
*   `destination`   Path where the file is downloaded.   
*   `force`         Overwrite destination file if it exists.   
*   `stdout`        Writable Stream in which commands output will be piped.   
*   `stderr`        Writable Stream in which commands error will be piped.   

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `downloaded`    Number of downloaded files

File example
```coffeescript

mecano.download
  source: 'file://path/to/something'
  destination: 'node-sigar.tgz'
, (err, downloaded) -> ...

```HTTP example
```coffeescript

mecano.download
  source: 'https://github.com/wdavidw/node-sigar/tarball/v0.0.1'
  destination: 'node-sigar.tgz'
, (err, downloaded) -> ...

```FTP example
```coffeescript

mecano.download
  source: 'ftp://myhost.com:3334/wdavidw/node-sigar/tarball/v0.0.1'
  destination: 'node-sigar.tgz'
  user: "johndoe",
  pass: "12345"
, (err, downloaded) -> ...

```File example

`exec` `execute([goptions], options, callback)`
-----------------------------------------------
Run a command locally or with ssh if the `host` is provided. Global options is
optional and is used in case where options is defined as an array of 
multiple commands. Note, `opts` inherites all the properties of `goptions`.

`goptions`            Global options includes:

*   `parallel`    Wether the command are run in sequential, parallel 
or limited concurrent mode. See the `node-each` documentation for more 
details. Default to sequential (false).
      
`options`           Include all conditions as well as:  

*   `cmd`           String, Object or array; Command to execute.   
*   `env`           Environment variables, default to `process.env`.   
*   `cwd`           Current working directory.   
*   `uid`           Unix user id.   
*   `gid`           Unix group id.   
*   `code`          Expected code(s) returned by the command, int or array of int, default to 0.  
*   `code_skipped`  Expected code(s) returned by the command if it has no effect, executed will not be incremented, int or array of int.   
*   `stdout`        Writable Stream in which commands output will be piped.   
*   `stderr`        Writable Stream in which commands error will be piped.   
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   

`callback`          Received parameters are:   

*   `err`           Error if any.   
*   `executed`      Number of executed commandes.   
*   `stdout`        Stdout value(s) unless `stdout` option is provided.   
*   `stderr`        Stderr value(s) unless `stderr` option is provided.   

`extract(options, callback)` 
----------------------------

Extract an archive. Multiple compression types are supported. Unless 
specified as an option, format is derived from the source extension. At the 
moment, supported extensions are '.tgz', '.tar.gz' and '.zip'.   

`options`           Command options include:   

*   `source`        Archive to decompress.   
*   `destination`   Default to the source parent directory.   
*   `format`        One of 'tgz' or 'zip'.   
*   `creates`       Ensure the given file is created or an error is send in the callback.   
*   `not_if_exists` Cancel extraction if file exists.   
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `extracted`     Number of extracted archives.   

`git`
-----

`options`           Command options include:   

*   `source`        Git source repository address.   
*   `destination`   Directory where to clone the repository.   
*   `revision`      Git revision, branch or tag.   
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   
*   `stdout`        Writable EventEmitter in which command output will be piped.   
*   `stderr`        Writable EventEmitter in which command error will be piped.   

`ini(options, callback`
-----------------------
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

`options`
*   `append`          Append the content to the destination file. If destination does not exist, the file will be created. When used with the `match` and `replace` options, it will append the `replace` value at the end of the file if no match if found and if the value is a string.   
*   `backup`          Create a backup, append a provided string to the filename extension or a timestamp if value is not a string.   
*   `content`         Object to stringify.   
*   `destination`     File path where to write content to or a callback.   
*   `from`            Replace from after this marker, a string or a regular expression.   
*   `local_source`    Treat the source as local instead of remote, only apply with "ssh" option.   
*   `match`           Replace this marker, a string or a regular expression.   
*   `merge`           Read the destination if it exists and merge its content.   
*   `replace`         The content to be inserted, used conjointly with the from, to or match options.   
*   `source`          File path from where to extract the content, do not use conjointly with content.   
*   `ssh`             Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   
*   `to`              Replace to before this marker, a string or a regular expression.   

`ln` `link(options, callback)`
------------------------------
Create a symbolic link and it's parent directories if they don't yet
exist.

`options`           Command options include:   

*   `source`        Referenced file to be linked.   
*   `destination`   Symbolic link to be created.   
*   `exec`          Create an executable file with an `exec` command.   
*   `mode`         Default to 0755.   

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `linked`        Number of created links.   

`mkdir(options, callback)`
--------------------------

Recursively create a directory. The behavior is similar to the Unix command `mkdir -p`. 
It supports an alternative syntax where options is simply the path of the directory
to create.

`options`           Command options include:   

*   `source`        Path or array of paths.   
*   `uid`           Unix user id.   
*   `gid`           Unix group id.  
*   `directory`     Alias for `source`
*   `destination`   Alias for `source`
*   `exclude`       Regular expression.   
*   `mode`         Default to 0755.  
*   `cwd`           Current working directory for relative paths.   

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `created`       Number of created directories

Simple usage:
```coffeescript

mecano.mkdir './some/dir', (err, created) ->
  console.log err?.message ? created
```
`mv` `move(options, callback)`
--------------------------------

More files and directories.

`options`           Command options include:   

*   `source`        File or directory to move.  
*   `destination`   Final name of the moved resource.    

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `moved`         Number of moved resources.

Example

  mecano.mv
```coffeescript
source: __dirname
desination: '/temp/my_dir'
(err, moved) ->
console.log "#{moved} dir moved"
```
`rm` `remove(options, callback)`
--------------------------------

Recursively remove files, directories and links. Internally, the function 
use the [rimraf](https://github.com/isaacs/rimraf) library.

`options`           Command options include:   

*   `source`        File, directory or pattern.  
*   `destination`   Alias for "source". 

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `removed`       Number of removed sources.   

Example
```coffeescript

mecano.rm './some/dir', (err, removed) ->
  console.log "#{removed} dir removed"

```Removing a directory unless a given file exists
```coffeescript

mecano.rm
  source: './some/dir'
  not_if_exists: './some/file'
, (err, removed) ->
  console.log "#{removed} dir removed"

```Removing multiple files and directories
```coffeescript

mecano.rm [
  { source: './some/dir', not_if_exists: './some/file' }
  './some/file'
], (err, removed) ->
  console.log "#{removed} dirs removed"
```
`render(options, callback)`
---------------------------

Render a template file At the moment, only the 
[ECO](http://github.com/sstephenson/eco) templating engine is integrated.   

`options`           Command options include:   

*   `engine`        Template engine to use, default to "eco"   
*   `content`       Templated content, bypassed if source is provided.   
*   `source`        File path where to extract content from.   
*   `destination`   File path where to write content to or a callback.   
*   `context`       Map of key values to inject into the template.   
*   `local_source`  Treat the source as local instead of remote, only apply with "ssh" option.   

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `rendered`      Number of rendered files.   

If destination is a callback, it will be called multiple times with the   
generated content as its first argument.
`service(options, callback)`
----------------------------

Install a service. For now, only yum over SSH.   

`options`           Command options include:   

*    name           Package name.   
*    startup        Run service daemon on startup.   
*    yum_name       Name used by the yum utility, default to "name".   
*    chk_name       Name used by the chkconfig utility, default to "srv_name" and "name".   
*    srv_name       Name used by the service utility, default to "name".   
*    start          Ensure the service is started, a boolean.   
*    stop           Ensure the service is stopped, a boolean.   
*   `stdout`        Writable Stream in which commands output will be piped.   
*   `stderr`        Writable Stream in which commands error will be piped.   

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `modified`      Number of action taken (installed, updated, started or stoped).   

`upload(options, callback)`
---------------------------

Upload a file to a remote location. Options are 
identical to the "write" function with the addition of 
the "binary" option.

`options`           Command options include:   

*   `binary`        Fast upload implementation, discard all the other option and use its own stream based implementation.   
*   `from`          Replace from after this marker, a string or a regular expression.   
*   `to`            Replace to before this marker, a string or a regular expression.   
*   `match`         Replace this marker, a string or a regular expression.   
*   `replace`       The content to be inserted, used conjointly with the from, to or match options.   
*   `content`       Text to be written.   
*   `source`        File path from where to extract the content, do not use conjointly with content.   
*   `destination`   File path where to write content to.   
*   `backup`        Create a backup, append a provided string to the filename extension or a timestamp if value is not a string.   

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `rendered`      Number of rendered files. 

`write(options, callback)`
--------------------------

Write a file or a portion of an existing file.

`options`             Command options include:   

*   `from`            Replace from after this marker, a string or a regular expression.   
*   `local_source`    Treat the source as local instead of remote, only apply with "ssh" option.   
*   `to`              Replace to before this marker, a string or a regular expression.   
*   `match`           Replace this marker, a string or a regular expression.   
*   `replace`         The content to be inserted, used conjointly with the from, to or match options.   
*   `content`         Text to be written, an alternative to source which reference a file.   
*   `source`          File path from where to extract the content, do not use conjointly with content.   
*   `destination`     File path where to write content to.   
*   `backup`          Create a backup, append a provided string to the filename extension or a timestamp if value is not a string.   
*   `append`          Append the content to the destination file. If destination does not exist, the file will be created.   
*   `ssh`             Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   

`callback`            Received parameters are:   

*   `err`             Error object if any.   
*   `rendered`        Number of rendered files.   

The option "append" allows some advance usages. If "append" is 
null, it will add the `replace` value at the end of the file 
if no match if found and if the value is a string. When used 
conjointly with the `match` and `replace` options, it gets even 
more interesting. If append is a string or a regular expression, 
it will place the "replace" string just after the match. An 
append string will be converted to a regular expression such as 
"test" will end up converted as the string "test" is similar to the 
RegExp /^.*test.*$/gm.

Example replacing part of a file using from and to markers
```coffeescript

mecano.write
  content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
  from: '# from\n'
  to: '# to'
  replace: 'my friend\n'
  destination: "#{scratch}/a_file"
, (err, written) ->
  # here we are\n# from\nmy friend\n# to\nyou coquin

```Example replacing a matched line by a string with
```coffeescript

mecano.write
  content: 'email=david(at)adaltas(dot)com\nusername=root'
  match: /(username)=(.*)/
  replace: '$1=david (was $2)'
  destination: "#{scratch}/a_file"
, (err, written) ->
  # email=david(at)adaltas(dot)com\nusername=david (was root)

```Example replacing part of a file using a regular expression
```coffeescript

mecano.write
  content: 'here we are\nlets try to replace that one\nyou coquin'
  match: /(.*try) (.*)/
  replace: ['my friend, $1']
  destination: "#{scratch}/a_file"
, (err, written) ->
  # here we are\nmy friend, lets try\nyou coquin

```Example replacing with the global and multiple lines options
```coffeescript

mecano.write
  content: '#A config file\n#property=30\nproperty=10\n#End of Config'
  match: /^property=.*$/mg
  replace: 'property=50'
  destination: "#{scratch}/replace"
, (err, written) ->
  '#A config file\n#property=30\nproperty=50\n#End of Config'

```Example appending a line after each line containing "property"
```coffeescript

mecano.write
  content: '#A config file\n#property=30\nproperty=10\n#End of Config'
  match: /^.*comment.*$/mg
  replace: '# comment'
  destination: "#{scratch}/replace"
, (err, written) ->
  '#A config file\n#property=30\n# comment\nproperty=50\n# comment\n#End of Config'
```