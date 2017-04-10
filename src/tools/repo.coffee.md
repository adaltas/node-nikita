
# `nikita.tools.repo(options, callback)`

Setup packet manager repository. Only support yum for now.

## Options

*   `source` (string)   
    The source file(s) containing the repository(ies)   
*   `local`
    Treat the source as local instead of remote, only apply with "ssh"
    option.
*   'replace' (String)   
    Globing expression used to match replaced files.
*   `verify`   
    Download the PGP keys if it's enabled in the repo file.
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.
*   `stdout` (stream.Writable)   
    Writable EventEmitter where diff information is written if option "diff" is
    "true"

## Example

```js
require('nikita').tools.repo({
  source: '/tmp/centos.repo',
  replace: 'CentOs*'
}, function(err, written){
  console.log(err ? err.message : 'Repo updated: ' + !!written);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering tools.repo", level: 'DEBUG', module: 'nikita/lib/tools/repo'
      throw Error "Missing source: #{options.source}" unless options.source
      options.verify ?= true
      options.local ?= false
      remote_files = []
      keys = []
      # Delete
      @call if: options.replace?, (_, callback) ->
        options.log message: "Searching repositories inside \"/etc/yum.repos.d/\"", level: 'DEBUG', module: 'nikita/lib/tools/repo'
        glob options.ssh, "/etc/yum.repos.d/#{options.replace}", (err, files) ->
          return callback err if err
          remote_files = for file in files
            continue if file is path.basename options.source
            "/etc/yum.repos.d/#{file}"
          callback()
      @system.remove remote_files
      # Write
      @file.types.yum_repo
        source: options.source
        local: options.local
        content: options.content
        mode: options.mode
        uid: options.uid
        gid: options.gid
        target: "/etc/yum.repos.d/#{path.basename options.source}"
      #Read GPG Keys
      @call 
        if: -> options.verify or @status -1
      , ->
        options.log "Download #{options.source}'s GPG keys", level: 'INFO', module: 'nikita/lib/tools/repo'
        @call (_, callback)->
          options.log "Read GPG keys from #{options.source}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
          fs.readFile options.ssh, options.source , 'utf8', (err, content) =>
            return callback err if err
            data  = misc.ini.parse_multi_brackets content
            keys = for name, section of data
              continue unless section.gpgcheck is '1'
              throw Error 'Missing data.gpgkey' unless section.gpgkey?
              continue unless /^http(s)??:\/\//.test section.gpgkey
              section.gpgkey
            callback()
        #Download GPG Keys
        @call
          if: -> keys.length isnt 0
        , ->
          @each keys, (options) ->
            gpgkey = options.key
            @file.download
              source: gpgkey
              target: "/etc/pki/rpm-gpg/#{path.basename gpgkey}"
            @system.execute
              if: -> @status -1
              cmd: "rpm --import  /etc/pki/rpm-gpg/#{path.basename gpgkey}"
      # Clean Metadata
      @system.execute
        cmd: 'yum clean metadata; yum repolist'
        if: -> @status()

## Dependencies

    fs = require 'ssh2-fs'
    string = require '../misc/string'
    path = require 'path'
    glob = require '../misc/glob'
    misc = require '../misc'
