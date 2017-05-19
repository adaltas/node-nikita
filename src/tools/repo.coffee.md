
# `nikita.tools.repo(options, callback)`

Setup packet manager repository. Only support yum for now.

## Options

* `source` (string)   
  The source file(s) containing the repository(ies)   
* `local`
  Treat the source as local instead of remote, only apply with "ssh"
  option.
* `content`   
  Content to write inside the file. can not be used with source
* 'replace' (String)   
  Globing expression used to match replaced files.
* 'clean' (Boolean)   
    Run yum clean metadata after repo file is placed. True by default.
* 'update' (Boolean)   
  Run yum update enabling only the ids present in repo file. Default to false.
* `verify`   
  Download the PGP keys if it's enabled in the repo file.
* `ssh` (object|ssh2)   
  Run the action on a remote server using SSH, an ssh2 instance or an
  configuration object used to initialize the SSH connection.
* `stdout` (stream.Writable)   
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
      throw Error "Can not specify source and content"if options.source and options.content
      throw Error "Missing source or content: " unless options.source or options.content
      options.target ?= "/etc/yum.repos.d/#{path.basename options.source}" if options.source?
      options.target = path.resolve '/etc/yum.repos.d', options.target
      throw Error " Missing target" unless options.target?
      options.verify ?= true
      options.local ?= false
      options.clean ?= true
      options.update ?= false
      remote_files = []
      keys = []
      repoids = []
      # Delete
      @call if: options.replace?, (_, callback) ->
        options.log message: "Searching repositories inside \"/etc/yum.repos.d/\"", level: 'DEBUG', module: 'nikita/lib/tools/repo'
        glob options.ssh, "/etc/yum.repos.d/#{options.replace}", (err, files) ->
          return callback err if err
          remote_files = for file in files
            continue if file is options.target
            file
          callback()
      @system.remove remote_files
      #download source
      @file.download
        if: options.source?
        source: options.source
        target: options.target
        headers: options.headers
        md5: options.md5
        proxy: options.proxy
        location: options.location
        cache: false
      # Write
      @file.types.yum_repo
        if: options.content?
        content: options.content
        mode: options.mode
        uid: options.uid
        gid: options.gid
        target: options.target
      # Read GPG Keys
      @call 
        if: -> options.verify
      , ->
        options.log "Download #{options.target}'s GPG keys", level: 'INFO', module: 'nikita/lib/tools/repo'
        @call (_, callback)->
          options.log "Read GPG keys from #{options.target}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
          fs.readFile options.ssh, options.target , 'utf8', (err, content) =>
            return callback err if err
            data  = misc.ini.parse_multi_brackets content
            keys = for name, section of data
              repoids.push name
              continue unless section.gpgcheck is '1'
              throw Error 'Missing data.gpgkey' unless section.gpgkey?
              continue unless /^http(s)??:\/\//.test section.gpgkey
              section.gpgkey
            callback()
        # Download GPG Keys
        @call
          if: -> keys.length isnt 0
        , ->
          @each keys, (options) ->
            gpgkey = options.key
            options.log "Downloading GPG keys from #{gpgkey}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
            @file.download
              source: gpgkey
              target: "/etc/pki/rpm-gpg/#{path.basename gpgkey}"
            @system.execute
              if: -> @status -1
              cmd: "rpm --import  /etc/pki/rpm-gpg/#{path.basename gpgkey}"
      # Clean Metadata
      @system.execute
        cmd: 'yum clean metadata; yum repolist'
        if: -> options.clean and @status()
      @call
        if: -> options.update and @status()
      , ->
        @system.execute
          cmd: "yum update -y --disablerepo=* --enablerepo=#{repoids.join(',')}; yum repolist"

## Dependencies

    fs = require 'ssh2-fs'
    string = require '../misc/string'
    path = require 'path'
    glob = require '../misc/glob'
    misc = require '../misc'
    url = require 'url'
