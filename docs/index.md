---
language: en
layout: page
title: "Node Mecano: Common functions for system deployment"
date: 2012-02-12T14:19:20.721Z
comments: false
sharing: false
footer: false
github: https://github.com/wdavidw/node-mecano
---
Mecano gather a set of functions usually used during system deployment. All the functions share a 
common API with flexible options.

`cp` `copy(options, callback)` Copy a file or a directory
----------------------------------------------------

`options`               Command options includes:   

*   `source`            The file or directory to copy.
*   `destination`       Where the file or directory is copied.
*   `not_if_exists`     Equals destination if true.
*   `chmod`             Permissions of the file or the parent directory

`callback`              Received parameters are:   

*   `err`               Error object if any.   
*   `copied`            Number of files or parent directories copied.

todo: preserve permissions if `chmod` is `true`

`download(options, callback)` Download files using various protocols
--------------------------------------------------------------------

The excellent [open-uri](https://github.com/publicclass/open-uri) module provides support for HTTP(S), 
file and FTP. All the options supported by open-uri are passed to it.

Note, GIT is not yet supported but documented as a wished feature.

`options`               Command options includes:   

*   `source`            File, HTTP URL, FTP, GIT repository. File is the default protocol if source is provided without a scheme.   
*   `destination`       Path where the file is downloaded.   
*   `force`             Overwrite destination file if it exists.   

`callback`              Received parameters are:   

*   `err`               Error object if any.   
*   `downloaded`        Number of downloaded files

Basic example:
```coffeescript
mecano.download
    source: 'https://github.com/wdavidw/node-sigar/tarball/v0.0.1'
    destination: 'node-sigar.tgz'
, (err, downloaded) ->
    path.exists 'node-sigar.tgz', (exists) ->
        assert.ok exists
```
`exec` `execute`([goptions], options, callback)` Run a command locally or with ssh
----------------------------------------------------------------------------------
Command is send over ssh if the `host` is provided. Global options is
optional and is used in case where options is defined as an array of 
multiple commands. Note, `opts` inherites all the properties of `goptions`.

`goptions`              Global options includes:

*   `parallel`          Wether the command are run in sequential, parallel 
or limited concurrent mode. See the `node-each` documentation for more 
details. Default to sequential (false).
            
`options`               Command options includes:   

*   `cmd`               String, Object or array; Command to execute.   
*   `env`               Environment variables, default to `process.env`.   
*   `cwd`               Current working directory.   
*   `uid`               Unix user id.   
*   `gid`               Unix group id.   
*   `code`              Expected code returned by the command, default to 0.   
*   `not_if_exists`     Dont run the command if the file exists.   
*   `host`              SSH host or IP address.   
*   `username`          SSH host or IP address.   
*   `stdout`            Writable EventEmitter in which command output will be piped.   
*   `stderr`            Writable EventEmitter in which command error will be piped.   

`callback`              Received parameters are:   

*   `err`               Error if any.   
*   `executed`          Number of executed commandes.   
*   `stdout`            Stdout value(s) unless `stdout` option is provided.   
*   `stderr`            Stderr value(s) unless `stderr` option is provided.   

`extract(options, callback)` Extract an archive
-----------------------------------------------

Multiple compression types are supported. Unless specified as 
an option, format is derived from the source extension. At the 
moment, supported extensions are '.tgz', '.tar.gz' and '.zip'.   

`options`               Command options includes:   

*   `source`            Archive to decompress.   
*   `destination`       Default to the source parent directory.   
*   `format`            One of 'tgz' or 'zip'.   
*   `creates`           Ensure the given file is created or an error is send in the callback.   
*   `not_if_exists`     Cancel extraction if file exists.   

`callback`              Received parameters are:   

*   `err`               Error object if any.   
*   `extracted`         Number of extracted archives.   

`git`
---------

`options`               Command options includes:   

*   `source`            Git source repository address.
*   `destination`       Directory where to clone the repository.
*   `revision`          Git revision, branch or tag.

`ln` `link(options, callback)` Create a symbolic link
------------------------------------------------

`options`               Command options includes:   

*   `source`            Referenced file to be linked.   
*   `destination`       Symbolic link to be created.   
*   `exec`              Create an executable file with an `exec` command.   
*   `chmod`             Default to 0755.   

`callback`              Received parameters are:   

*   `err`               Error object if any.   
*   `linked`            Number of created links.   

`mkdir(options, callback)` Recursively create a directory
---------------------------------------------------------

The behavior is similar to the Unix command `mkdir -p`

`options`               Command options includes:   

*   `directory`         Path or array of paths.   
*   `exclude`           Regular expression.   
*   `chmod`             Default to 0755.   

`callback`              Received parameters are:   

*   `err`               Error object if any.   
*   `created`           Number of created directories

`rm` `remove(options, callback)` Recursively remove a file or directory
------------------------------------------------------

Internally, the function use the [rimraf](https://github.com/isaacs/rimraf) 
library.

`options`               Command options includes:   

*   `source`            File or directory.   
*   `options`           Options passed to rimraf.   

`callback`              Received parameters are:   

*   `err`               Error object if any.   
*   `deleted`           Number of deleted sources.   

Exemple
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
`render(options, callback)` Render a template file
--------------------------------------------------

At the moment, only the ECO templating engine is integrated.

`options`               Command options includes:   

*   `engine`            Template engine to use, default to "eco"
*   `content`           Templated content, bypassed if source is provided.
*   `source`            File path where to extract content from.
*   `destination`       File path where to write content to.
*   `context`           Map of key values to inject into the template.

`callback`              Received parameters are:   

*   `err`               Error object if any.   
*   `rendered`          Number of rendered files.   
