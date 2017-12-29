
# `nikita.tools.repo(options, callback)`

Setup packet manager repository. Only support yum for now.

## Options

* `source` (string)   
  The source file(s) containing the repository(ies)   
* `local` (boolean)   
  Treat the source as local instead of remote, only apply with "ssh"
  option.   
* `content`   
  Content to write inside the file. can not be used with source.   
* `clean` (String)   
  Globing expression used to match replaced files.   
* `clean` (Boolean)   
  Run yum clean metadata after repo file is placed. True by default.   
* `gpg_dir` (string)   
  Directory storing GPG keys.   
* `update` (Boolean)   
  Run yum update enabling only the ids present in repo file. Default to false.   
* `verify`   
  Download the PGP keys if it's enabled in the repo file, keys are by default
  placed inside "/etc/pki/rpm-gpg" defined by the gpg_dir option and the 
  filename is derivated from the url.   

## Example

```js
require('nikita').tools.repo({
  source: '/tmp/centos.repo',
  clean: 'CentOs*'
}, function(err, written){
  console.log(err ? err.message : 'Repo updated: ' + !!written);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering tools.repo", level: 'DEBUG', module: 'nikita/lib/tools/repo'
      # SSH connection
      ssh = @ssh options.ssh
      # Options
      throw Error "Can not specify source and content"if options.source and options.content
      throw Error "Missing source or content: " unless options.source or options.content
      options.target ?= "/etc/yum.repos.d/#{path.basename options.source}" if options.source?
      options.target = path.posix.resolve '/etc/yum.repos.d', options.target
      throw Error " Missing target" unless options.target?
      options.verify ?= true
      options.local ?= false
      options.clean ?= true
      options.update ?= false
      options.gpg_dir ?= '/etc/pki/rpm-gpg'
      remote_files = []
      repoids = []
      # Delete
      @call if: options.clean?, (_, callback) ->
        options.log message: "Searching repositories inside \"/etc/yum.repos.d/\"", level: 'DEBUG', module: 'nikita/lib/tools/repo'
        glob ssh, "/etc/yum.repos.d/#{options.clean}", (err, files) ->
          return callback err if err
          remote_files = for file in files
            continue if file is options.target
            file
          callback()
      @call -> @system.remove remote_files
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
        keys = []
        options.log "Download #{options.target}'s GPG keys", level: 'INFO', module: 'nikita/lib/tools/repo'
        @call (_, callback)->
          options.log "Read GPG keys from #{options.target}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
          fs.readFile ssh, options.target , 'utf8', (err, content) =>
            return callback err if err
            data  = misc.ini.parse_multi_brackets content
            keys = for name, section of data
              repoids.push name
              continue unless section.gpgcheck is '1'
              throw Error 'Missing gpgkey' unless section.gpgkey?
              continue unless /^http(s)??:\/\//.test section.gpgkey
              section.gpgkey
            callback()
        # Download GPG Keys
        @call -> for key in keys
          options.log "Downloading GPG keys from #{key}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
          @file.download
            source: key
            target: "#{options.gpg_dir}/#{path.basename key}"
          @system.execute
            if: -> @status -1
            cmd: "rpm --import #{options.gpg_dir}/#{path.basename key}"
      # Clean Metadata
      @system.execute
        if: -> options.clean and @status()
        cmd: 'yum clean metadata; yum repolist -y'
      @system.execute
        if: -> options.update and @status()
        cmd: "yum update -y --disablerepo=* --enablerepo=#{repoids.join(',')}; yum repolist"

## Dependencies

    fs = require 'ssh2-fs'
    string = require '../misc/string'
    path = require 'path'
    glob = require '../misc/glob'
    misc = require '../misc'
    url = require 'url'
