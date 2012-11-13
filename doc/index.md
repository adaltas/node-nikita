---
language: en
layout: page
title: "Node Mecano: Common functions for system deployment"
date: 2012-11-13T18:56:18.030Z
comments: false
sharing: false
footer: false
github: https://github.com/wdavidw/node-mecano
---
Mecano gather a set of functions usually used during system deployment. All the functions share a 
common API with flexible options.

p` `copy(options, callback)`
----------------------------

py a file.

ptions`         Command options include:   

  `source`      The file or directory to copy.
  `destination`     Where the file or directory is copied.
  `force`       Copy the file even if one already exists.
  `not_if_exists`   Equals destination if true.
  `chmod`       Permissions of the file or the parent directory

allback`        Received parameters are:   

  `err`         Error object if any.   
  `copied`      Number of files or parent directories copied.

do:
  deal with directories
  preserve permissions if `chmod` is `true`
  Compare files with checksum

ownload(options, callback)`
---------------------------

wnload files using various protocols. The excellent 
pen-uri](https://github.com/publicclass/open-uri) module provides support for HTTP(S), 
le and FTP. All the options supported by open-uri are passed to it.

te, GIT is not yet supported but documented as a wished feature.

ptions`         Command options include:   

  `source`      File, HTTP URL, FTP, GIT repository. File is the default protocol if source is provided without a scheme.   
  `destination` Path where the file is downloaded.   
  `force`       Overwrite destination file if it exists.   

allback`        Received parameters are:   

  `err`         Error object if any.   
  `downloaded`  Number of downloaded files

sic example:
  mecano.download
```coffeescript
source: 'https://github.com/wdavidw/node-sigar/tarball/v0.0.1'
destination: 'node-sigar.tgz'
(err, downloaded) ->
fs.exists 'node-sigar.tgz', (exists) ->
  assert.ok exists
```
xec` `execute([goptions], options, callback)`
---------------------------------------------
n a command locally or with ssh if the `host` is provided. Global options is
tional and is used in case where options is defined as an array of 
ltiple commands. Note, `opts` inherites all the properties of `goptions`.

options`        Global options includes:

  `parallel`    Wether the command are run in sequential, parallel 
 limited concurrent mode. See the `node-each` documentation for more 
tails. Default to sequential (false).
```coffeescript

ns`         Include all conditions as well as:  

md`         String, Object or array; Command to execute.   
nv`         Environment variables, default to `process.env`.   
wd`         Current working directory.   
id`         Unix user id.   
id`         Unix group id.   
ode`        Expected code(s) returned by the command, int or array of int, default to 0.   
ost`        SSH host or IP address.   
sername`    SSH host or IP address.   
tdout`      Writable EventEmitter in which command output will be piped.   
tderr`      Writable EventEmitter in which command error will be piped.   

```allback`        Received parameters are:   

  `err`         Error if any.   
  `executed`    Number of executed commandes.   
  `stdout`      Stdout value(s) unless `stdout` option is provided.   
  `stderr`      Stderr value(s) unless `stderr` option is provided.   

xtract(options, callback)` 
--------------------------

tract an archive. Multiple compression types are supported. Unless 
ecified asan option, format is derived from the source extension. At the 
ment, supported extensions are '.tgz', '.tar.gz' and '.zip'.   

ptions`             Command options include:   

  `source`          Archive to decompress.   
  `destination`     Default to the source parent directory.   
  `format`          One of 'tgz' or 'zip'.   
  `creates`         Ensure the given file is created or an error is send in the callback.   
  `not_if_exists`   Cancel extraction if file exists.   

allback`            Received parameters are:   

  `err`             Error object if any.   
  `extracted`       Number of extracted archives.   

it`
---

ptions`             Command options include:   

  `source`          Git source repository address.
  `destination`     Directory where to clone the repository.
  `revision`        Git revision, branch or tag.

n` `link(options, callback)`
----------------------------
eate a symbolic link and it's parent directories if they don't yet
ist.

ptions`             Command options include:   

  `source`          Referenced file to be linked.   
  `destination`     Symbolic link to be created.   
  `exec`            Create an executable file with an `exec` command.   
  `chmod`           Default to 0755.   

allback`            Received parameters are:   

  `err`             Error object if any.   
  `linked`          Number of created links.   

kdir(options, callback)`
------------------------

cursively create a directory. The behavior is similar to the Unix command `mkdir -p`. 
 supports an alternative syntax where options is simply the path of the directory
 create.

ptions`           Command options include:   

  `source`        Path or array of paths.   
  `directory`     Shortcut for `source`
  `exclude`       Regular expression.   
  `chmod`         Default to 0755.  
  `cwd`           Current working directory for relative paths.   

allback`          Received parameters are:   

  `err`           Error object if any.   
  `created`       Number of created directories

mple usage:

  mecano.mkdir './some/dir', (err, created) ->
```coffeescript
console.log err?.message ? created
```
m` `remove(options, callback)`
------------------------------

cursively remove a file or directory. Internally, the function 
e the [rimraf](https://github.com/isaacs/rimraf) library.

ptions`         Command options include:   

  `source`      File or directory.   

allback`        Received parameters are:   

  `err`         Error object if any.   
  `deleted`     Number of deleted sources.   

ample

  mecano.rm './some/dir', (err, removed) ->
```coffeescript
console.log "#{removed} dir removed"

```moving a directory unless a given file exists

  mecano.rm
```coffeescript
source: './some/dir'
not_if_exists: './some/file'
(err, removed) ->
console.log "#{removed} dir removed"

```moving multiple files and directories

  mecano.rm [
    { source: './some/dir', not_if_exists: './some/file' }
    './some/file'
  ], (err, removed) ->
```coffeescript
console.log "#{removed} dirs removed"
```
ender(options, callback)`
-------------------------

nder a template file At the moment, only the 
CO](http://github.com/sstephenson/eco) templating engine is integrated.

ptions`           Command options include:   

  `engine`        Template engine to use, default to "eco"
  `content`       Templated content, bypassed if source is provided.
  `source`        File path where to extract content from.
  `destination`   File path where to write content to.
  `context`       Map of key values to inject into the template.

allback`          Received parameters are:   

  `err`           Error object if any.   
  `rendered`      Number of rendered files.   
