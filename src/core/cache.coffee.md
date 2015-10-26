
# `cache(options, callback)`

Download a file a place it on a local or remote folder for later usage.

## Options

*   `cache_dir` (path)   
    If local_cache is not a string, the cache file path is resolved from cache dir and cache file.
    By default: './'   
*   `cache_file` (string | boolean)   
    Alias for "destination".   
*   `destination` (string | boolean)   
    Cache the file on the executing machine, equivalent to cache unless an ssh connection is
    provided. If a string is provided, it will be the cache path.   
    By default: basename of source   
*   `fail` (boolean)
    Send an error if the HTTP response code is invalid. Similar to the curl
    option of the same name.   
*   `force` (boolean)   
    Overwrite destination file if it exists, bypass md5 verification.   
*   `proxy` (string)   
     Use the specified HTTP proxy. If the port number is not specified, it is
     assumed at port 1080. See curl(1) man page.   
 *   `source` (path)   
     File, HTTP URL, FTP, GIT repository. File is the default protocol if source
     is provided without any.   

## Callback parameters

*   `err`
    Error object if any.
*   `status`
    Wether the file was downloaded or not.

## HTTP example

```coffee
mecano.download
  source: 'https://github.com/wdavidw/node-mecano/tarball/v0.0.1'
  cache_dir: '/var/tmp'
, (err, status) -> ...
```

## Source Code

    module.exports = (options, callback) ->
      return callback Error "Missing source: '#{options.source}'" unless options.source
      return callback Error "Missing one of 'destination', 'cache_file' or 'cache_dir' option" unless options.cache_file or options.destination or options.cache_dir
      options.destination ?= options.cache_file
      options.destination ?= path.basename options.source
      options.destination = path.resolve options.cache_dir, options.destination
      options.source = options.source.substr 7 if /^file:\/\//.test options.source
      if options.md5?
        return callback new Error "Invalid MD5 Hash:#{options.md5}" unless typeof options.md5 in ['string', 'boolean']
        algo = 'md5'
        hash = options.md5
      else if options.sha1?
        return callback new Error "Invalid SHA-1 Hash:#{options.sha1}" unless typeof options.sha1 in ['string', 'boolean']
        algo = 'sha1'
        hash = options.sha1
      else
        algo = 'md5'
        hash = false
      u = url.parse options.source
      @call
        handler: (_, callback) ->
          unless u.protocol is null
            options.log? "Mecano `cache`: bypass source hash computation for non-file protocols [WARN]"
            return callback()
          return callback() if hash isnt true
          misc.file.hash options.ssh, options.source, algo, (err, value) ->
            return callback err if err
            options.log? "Mecano `cache`: computed hash value is '#{value}' [INFO]"
            hash = value
            callback()
      # Download the file if
      # - file doesnt exist
      # - option force is provided
      # - hash isnt true and doesnt match
      @call
        shy: true
        handler: (_, callback) ->
          options.log? "Mecano `cache`: Check if destination (#{options.destination}) exists [DEBUG]"
          ssh2fs.exists options.ssh, options.destination, (err, exists) =>
            return callback err if err
            if exists
              options.log? "Mecano `cache`: destination exists [INFO]"
              # If no checksum , we ignore MD5 check
              if options.force
                options.log? "Mecano `cache`: Force mode, cache will be overwritten [DEBUG]"
                return callback null, true
              else if hash and typeof hash is 'string'
                # then we compute the checksum of the file
                options.log? "Mecano `cache`: comparing #{algo} hash [DEBUG]"
                misc.file.hash options.ssh, options.destination, algo, (err, c_hash) ->
                  return callback err if err
                  # And compare with the checksum provided by the user
                  if hash is c_hash
                    options.log? "Mecano `cache`: Hashes match, skipping [DEBUG]"
                    return callback null, false
                  options.log? "Mecano `cache`: Hashes don't match, delete then re-download [WARN]"
                  ssh2fs.unlink options.ssh, options.destination, (err) ->
                    return callback err if err
                    callback null, true
              else
                options.log? "Mecano `cache`: destination exists, check disabled, skipping [DEBUG]"
                callback null, false
            else
              options.log? "Mecano `cache`: destination does not exists [INFO]"
              callback null, true
      , (err, status) ->
        @end() unless status
      # Place into cache
      if u.protocol in protocols_http
        fail = if options.fail then "--fail" else ''
        k = if u.protocol is 'https:' then '-k' else ''
        cmd = "curl #{fail} #{k} -s #{options.source} -o #{options.destination}"
        cmd += " -x #{options.proxy}" if options.proxy
        @mkdir path.dirname options.destination
        @execute
          cmd: cmd
          not_if_exists: options.destination
      else
        @mkdir # todo: copy shall handle this
          destination: "#{path.dirname options.destination}"
        @copy
          source: "#{options.source}"
          destination: "#{options.destination}"
      @then (err, status) ->
        callback err, status, options.destination
      
    module.exports.protocols_http = protocols_http = ['http:', 'https:']
    module.exports.protocols_ftp = protocols_ftp = ['ftp:', 'ftps:']

## Dependencies

    path = require 'path'
    url = require 'url'
    ssh2fs = require 'ssh2-fs'
    misc = require '../misc'
    curl = require '../misc/curl'
