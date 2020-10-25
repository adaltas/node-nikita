
# `nikita.tools.repo`

Setup packet manager repository. Only support yum for now.

## Options

* `source` (string)   
  The source file(s) containing the repository(ies)   
* `local` (boolean)   
  Treat the source as local instead of remote, only apply with "ssh"
  option.   
* `content`   
  Content to write inside the file. can not be used with source.   
* `clean` (string)   
  Globing expression used to match replaced files, path will resolve to
  '/etc/yum.repos.d' if relative.   
* `gpg_dir` (string)   
  Directory storing GPG keys.   
* `target` (string)   
  Path of the repository definition file, relative to '/etc/yum.repos.d'.
* `update` (boolean)   
  Run yum update enabling only the ids present in repo file. Default to false.   
* `verify`   
  Download the PGP keys if it's enabled in the repo file, keys are by default
  placed inside "/etc/pki/rpm-gpg" defined by the gpg_dir option and the 
  filename is derivated from the url.   

## Example

```js
require('nikita')
.tools.repo({
  source: '/tmp/centos.repo',
  clean: 'CentOs*'
}, function(err, {status}){
  console.info(err ? err.message : 'Repo updated: ' + status);
});
```

## Source Code

    module.exports = ({config}) ->
      @log message: "Entering tools.repo", level: 'DEBUG', module: 'nikita/lib/tools/repo'
      # SSH connection
      ssh = @ssh config.ssh
      # Options
      throw Error "Can not specify source and content"if config.source and config.content
      throw Error "Missing source or content: " unless config.source or config.content
      # TODO wdavidw 180115, target should be mandatory and not default to the source filename
      config.target ?= path.resolve "/etc/yum.repos.d", path.basename config.source if config.source?
      throw Error "Missing target" unless config.target?
      config.target = path.posix.resolve '/etc/yum.repos.d', config.target
      config.verify ?= true
      throw Error "Invalid Option: option 'clean' must be a 'string'" if config.clean and typeof config.clean isnt 'string'
      config.clean = path.resolve '/etc/yum.repos.d', config.clean if config.clean
      config.update ?= false
      config.gpg_dir ?= '/etc/pki/rpm-gpg'
      remote_files = []
      repoids = []
      # Delete
      @call
        if: config.clean
      , (_, callback) ->
        @log message: "Searching repositories inside \"/etc/yum.repos.d/\"", level: 'DEBUG', module: 'nikita/lib/tools/repo'
        @file.glob config.clean, (err, {files}) ->
          return callback err if err
          remote_files = for file in files
            continue if file is config.target
            file
          callback()
      @call -> @system.remove remote_files
      # Download source
      @file.download
        if: config.source?
        source: config.source
        target: config.target
        headers: config.headers
        md5: config.md5
        proxy: config.proxy
        location: config.location
        cache: false
      # Write
      @file.types.yum_repo
        if: config.content?
        content: config.content
        mode: config.mode
        uid: config.uid
        gid: config.gid
        target: config.target
      # Parse the definition file
      keys = []
      @call ->
        @log "Read GPG keys from #{config.target}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
        @fs.readFile
          target: config.target
          encoding: 'utf8'
        , (err, {data}) =>
          throw err if err
          data  = misc.ini.parse_multi_brackets data
          keys = for name, section of data
            repoids.push name
            continue unless section.gpgcheck is '1'
            throw Error 'Missing gpgkey' unless section.gpgkey?
            continue unless /^http(s)??:\/\//.test section.gpgkey
            section.gpgkey
      # Download GPG Keys
      @call
        if: config.verify
      , ->
        for key in keys
          @log "Downloading GPG keys from #{key}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
          @file.download
            source: key
            target: "#{config.gpg_dir}/#{path.basename key}"
          @execute
            if: -> @status -1
            cmd: "rpm --import #{config.gpg_dir}/#{path.basename key}"
      # Clean Metadata
      @execute
        if: -> path.relative('/etc/yum.repos.d', config.target) isnt '..' and @status()
        # wdavidw: 180114, was "yum clean metadata", ensure an appropriate
        # explanation is provided in case of revert.
        # expire-cache is much faster,  It forces yum to go redownload the small
        # repo files only, then if there's newer repo data, it will downloaded it.
        cmd: 'yum clean expire-cache; yum repolist -y'
      @call 
        if: -> config.update and @status()
      , ->
        @execute
          cmd: """
          yum update -y --disablerepo=* --enablerepo='#{repoids.join(',')}'
          yum repolist
          """
          trap: true

## Dependencies

    path = require 'path'
    misc = require '@nikitajs/core/lib/misc'
    string = require '@nikitajs/core/lib/misc/string'
    url = require 'url'
