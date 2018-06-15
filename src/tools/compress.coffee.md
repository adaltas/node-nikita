
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
* `clean`   
  Remove the source file or directory

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
      @log message: "Entering compress", level: 'DEBUG', module: 'nikita/lib/tools/compress'
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
        format = module.exports.ext_to_type options.target
      # Run compression
      @system.execute switch format
        when 'tgz' then "tar czf #{options.target} -C #{dir} #{name}"
        when 'tar' then "tar cf  #{options.target} -C #{dir} #{name}"
        when 'bz2' then "tar cjf #{options.target} -C #{dir} #{name}"
        when 'xz'  then "tar cJf #{options.target} -C #{dir} #{name}"
        when 'zip' then "(cd #{dir} && zip -r #{options.target} #{name} && cd -)"
      @system.remove
        if: options.clean
        source: options.source

## Type of extension

    module.exports.type_to_ext = (type) ->
      return ".#{type}" if type in ['tgz', 'tar', 'zip', 'bz2', 'xz']
      throw Error "Unsupported Type: #{JSON.stringify(type)}"

## Extention to type

Convert a full path, a filename or an extension into a supported compression 
type.

    module.exports.ext_to_type = (name) ->
      if /((.+\.)|^\.|^)(tar\.gz|tgz)$/.test name then 'tgz'
      else if /((.+\.)|^\.|^)tar$/.test name then 'tar'
      else if /((.+\.)|^\.|^)zip$/.test name then 'zip'
      else if /((.+\.)|^\.|^)bz2$/.test name then 'bz2'
      else if /((.+\.)|^\.|^)xz$/.test name then 'xz'
      else
        throw Error "Unsupported Extension: #{JSON.stringify(path.extname name)}"

## Dependencies

    path = require 'path'
