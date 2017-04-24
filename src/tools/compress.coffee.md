
# `nikita.tools.compress(options, [callback])`

Compress an archive. Multiple compression types are supported. Unless
specified as an option, format is derived from the source extension. At the
moment, supported extensions are '.tgz', '.tar.gz', 'tar.xz', 'tar.bz2' and '.zip'.

## Options

* `format`   
  One of 'tgz', 'tar', 'xz', 'bz2' or 'zip'.   
* `source`   
  Archive to compress.   
* `target`   
  Default to the source parent directory.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file was compressed.   

## Example

```javascript
require('nikita').tools.compress({
  source: '/path/to/file.tgz'
  destation: '/tmp'
}, function(err, status){
  console.log(err ? err.message : 'File was compressed: ' + status);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering compress", level: 'DEBUG', module: 'nikita/lib/tools/compress'
      # Validate parameters
      throw Error "Missing source: #{options.source}" unless options.source
      throw Error "Missing target: #{options.target}" unless options.target
      options.source = path.normalize options.source
      options.target = path.normalize options.target
      dir = path.dirname options.source
      name = path.basename options.source
      # Deal with format option
      if options.format?
        format = options.format
      else
        if /\.(tar\.gz|tgz)$/.test options.target
          format = 'tgz'
        else if /\.tar$/.test options.target
          format = 'tar'
        else if /\.zip$/.test options.target
          format = 'zip'
        else if /\.bz2$/.test options.target
          format = 'bz2'
        else if /\.xz$/.test options.target
          format = 'xz'
        else
          ext = path.extname options.source
          throw Error "Unsupported extension, got #{JSON.stringify(ext)}"
      # Run compression
      @system.execute switch format
        when 'tgz' then "tar czf #{options.target} -C #{dir} #{name}"
        when 'tar' then "tar cf  #{options.target} -C #{dir} #{name}"
        when 'bz2' then "tar cjf #{options.target} -C #{dir} #{name}"
        when 'xz'  then "tar cJf #{options.target} -C #{dir} #{name}"
        when 'zip' then "(cd #{dir} && zip -r #{options.target} #{name} && cd -)"

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
