
# `cache(options, callback)`

Download a file a place it on a local or remote folder for later usage.

## Options

*   `source` (path)   
    File, HTTP URL, FTP, GIT repository. File is the default protocol if source
    is provided without any.   
*   `cache_dir` (path)   
    If local_cache is not a string, the cache file path is resolved from cache dir and cache file.
    By default: './'   
*   `cache_file` (string | boolean)   
    Cache the file on the executing machine, equivalent to cache unless an ssh connection is
    provided. If a string is provided, it will be the cache path.   
    By default: basename of source   

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

    module.exports = (options) ->
      return callback new Error "Missing source: '#{options.source}'" unless options.source
      return callback new Error "Missing one of 'cache_file' or 'cache_dir' option" unless options.cache_file or options.cache_dir
      options.cache_file ?= path.basename options.source
      options.cache_file = path.resolve options.cache_dir, options.cache_file
      u = url.parse options.source
      if u.protocol in protocols_http
        k = if u.protocol is 'https:' then '-k' else ''
        cmd = "curl #{k} -s #{options.source} -o #{options.cache_file}"
        cmd += " -x #{options.proxy}" if options.proxy
        # console.log cmd
        # console.log path.dirname options.cache_file
        @mkdir path.dirname options.cache_file
        @execute
          cmd: cmd
          unless_exists: options.cache_file
      
    module.exports.protocols_http = protocols_http = ['http:', 'https:']
    module.exports.protocols_ftp = protocols_ftp = ['ftp:', 'ftps:']

## Dependencies

    path = require 'path'
    url = require 'url'
