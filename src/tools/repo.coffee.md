
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
require('nikita').tools.repo({
  source: '/tmp/centos.repo',
  clean: 'CentOs*'
}, function(err, {status}){
  console.info(err ? err.message : 'Repo updated: ' + !!status);
});
```

## Source Code

    module.exports = (options) ->
      @log message: "Entering tools.repo", level: 'DEBUG', module: 'nikita/lib/tools/repo'
      # SSH connection
      ssh = @ssh options.ssh
      # Options
      throw Error "Can not specify source and content"if options.source and options.content
      throw Error "Missing source or content: " unless options.source or options.content
      # TODO wdavidw 180115, target should be mandatory and not default to the source filename
      options.target ?= path.resolve "/etc/yum.repos.d", path.basename options.source if options.source?
      throw Error "Missing target" unless options.target?
      options.target = path.posix.resolve '/etc/yum.repos.d', options.target
      options.verify ?= true
      throw Error "Invalid Option: option 'clean' must be a 'string'" if options.clean and typeof options.clean isnt 'string'
      options.clean = path.resolve '/etc/yum.repos.d', options.clean if options.clean
      options.update ?= false
      options.gpg_dir ?= '/etc/pki/rpm-gpg'
      remote_files = []
      repoids = []
      # Delete
      @call
        if: options.clean
      , (_, callback) ->
        @log message: "Searching repositories inside \"/etc/yum.repos.d/\"", level: 'DEBUG', module: 'nikita/lib/tools/repo'
        glob ssh, options.clean, (err, files) ->
          return callback err if err
          remote_files = for file in files
            continue if file is options.target
            file
          callback()
      @call -> @system.remove remote_files
      # Download source
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
      # Parse the definition file
      keys = []
      @log "Read GPG keys from #{options.target}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
      @fs.readFile
        ssh: options.ssh
        target: options.target
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
        if: options.verify
      , ->
        for key in keys
          @log "Downloading GPG keys from #{key}", level: 'DEBUG', module: 'nikita/lib/tools/repo'
          @file.download
            source: key
            target: "#{options.gpg_dir}/#{path.basename key}"
          @system.execute
            if: -> @status -1
            cmd: "rpm --import #{options.gpg_dir}/#{path.basename key}"
      # Clean Metadata
      @system.execute
        if: -> path.relative('/etc/yum.repos.d', options.target) isnt '..' and @status()
        # wdavidw: 180114, was "yum clean metadata", ensure an appropriate
        # explanation is provided in case of revert.
        # expire-cache is much faster,  It forces yum to go redownload the small
        # repo files only, then if there's newer repo data, it will downloaded it.
        cmd: 'yum clean expire-cache; yum repolist -y'
      @call 
        if: -> options.update and @status()
      , ->
        @system.execute
          cmd: """
          yum update -y --disablerepo=* --enablerepo='#{repoids.join(',')}'
          yum repolist
          """
          trap: true

## Dependencies

    string = require '../misc/string'
    path = require 'path'
    glob = require '../misc/glob'
    misc = require '../misc'
    url = require 'url'
