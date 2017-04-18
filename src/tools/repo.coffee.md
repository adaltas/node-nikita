
# `nikita.tools.repo(options, callback)`

Setup packet manager repository. Only support yum for now.

## Options

*   `local` (boolean)
    Treat the source as local instead of remote, only apply with "ssh"
    option, default to "false".
*   `replace` (String)   
    Globing expression used to match replaced files.
*   `update` (boolean)   
    Cleanup cache and update repo list, default to "false".   
*   `source` (string)   
    The source file(s) containing the repository(ies), required.   
*   `verify` (boolean)   
    Download the PGP keys if it's enabled in the repo file, default to "true".

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
      options.source = path.resolve '/etc/yum.repos.d', options.source
      options.target ?= path.basename options.source
      options.target = path.resolve '/etc/yum.repos.d', options.target
      options.verify ?= true
      options.local ?= false
      remote_files = []
      keys = []
      file_name = path.basename options.source
      options.target ?= path.resolve '/etc/yum.repos.d/', file_name
      # Delete
      @call if: options.replace?, (_, callback) ->
        options.log message: "Searching repositories inside \"/etc/yum.repos.d/\"", level: 'DEBUG', module: 'nikita/lib/tools/repo'
        glob options.ssh, "/etc/yum.repos.d/#{options.replace}", (err, files) ->
          return callback err if err
          remote_files = for file in files
            continue if file is file_name
            "/etc/yum.repos.d/#{file}"
          callback()
      @system.remove remote_files
      # Write
<<<<<<< HEAD
      @call ->
        cache  = (url.parse options.source).protocol in ['http:', 'https:']
        tmp_dir = "/tmp/nikita_repo_#{Date.now()}"
        @system.mkdir
          target: tmp_dir
          shy: true
        @file.cache
          if: cache
          source: options.source
          target: file_name
          cache_dir: tmp_dir
          cache_local: options.local
          headers: options.headers
          md5: options.md5
          proxy: options.proxy
          location: options.location
          shy: true
        @file.types.yum_repo
          source: if cache then "#{tmp_dir}/#{file_name}" else options.source
          local: options.local
          content: options.content
          mode: options.mode
          uid: options.uid
          gid: options.gid
          target: options.target
        @system.remove
          target: tmp_dir
          shy: true
=======
      @file.types.yum_repo
        source: options.source
        local: options.local
        content: options.content
        mode: options.mode
        uid: options.uid
        gid: options.gid
        target: options.target
>>>>>>> tools.repo: fix path resolution
      #Read GPG Keys
      @call 
        if: -> options.verify
      , ->
        options.log "Download #{options.source}'s GPG keys", level: 'INFO', module: 'nikita/lib/tools/repo'
        @call (_, callback)->
          options.log "Read GPG keys from #{options.source}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
          fs.readFile options.ssh, options.target , 'utf8', (err, content) =>
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
        if: -> options.update and @status()

## Dependencies

    fs = require 'ssh2-fs'
    string = require '../misc/string'
    path = require 'path'
    glob = require '../misc/glob'
    misc = require '../misc'
    url = require 'url'
