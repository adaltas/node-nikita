
# `nikita.file.render(options, [callback])`

Render a template file. The following templating engines are
integrated. More are added on demand.      

*   [ECO](http://github.com/sstephenson/eco) (default)   
*   [Nunjucks](http://mozilla.github.io/nunjucks/) ("*.j2")   

## Options

* `engine`   
  Template engine to use, default to "eco".   
* `content`   
  Templated content, bypassed if source is provided.   
* `source`   
  File path where to extract content from.   
* `target`   
  File path where to write content to or a callback.   
* `context`   
  Map of key values to inject into the template.   
* `filters` (function)   
  Filter function to extend the nunjucks engine.   
* `local`   
  Treat the source as local instead of remote, only apply with "ssh"
  option.   
* `skip_empty_lines`   
  Remove empty lines.   
* `uid`   
  File user name or user id.   
* `gid`   
  File group name or group id.   
* `mode`   
  File mode (permission and sticky bits), default to `0644`, in the form of
  `{mode: 0o744}` or `{mode: "744"}`.   

If target is a callback, it will be called with the generated content as
its first argument.   

## Custom Filters

Nunjucks allow to add custom filters. Nikita provides some custom filters listed below.
These filters are implemented misc/string. They can be overriden through the filters
parameters   

* `isString`   
  return true if the variable is a string   
* `isArray`   
  return true if the variable is an array   
* `isObject`   
  return true if the variable is an object. Return false if the variable is an array.   
* `isEmpty`   
  return true if the variable is `null`, `undefined`, `''`, `[]`, or `{}`   

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Value is true if rendered file was created or modified.   

## Rendering with Nunjucks

```js
require('nikita').file.render({
  source: './some/a_template.j2',
  target: '/tmp/a_file',
  context: {
    username: 'a_user'
  }
}, function(err, status){
  console.log(err ? err.message : 'File rendered: ' + !!status);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering file.render", level: 'DEBUG', module: 'nikita/lib/file/render'
      # SSH connection
      ssh = @ssh options.ssh
      # Validate parameters
      throw Error 'Required option: source or content' unless options.source or options.content
      throw Error 'Required option: target' unless options.target
      throw Error 'Required option: context' unless options.context
      # Start real work
      @call (_, callback) ->
        return callback() unless options.source
        sshOrLocal = if options.local then false else ssh
        fs.exists sshOrLocal, options.source, (err, exists) ->
          return callback Error "Invalid source, got #{JSON.stringify(options.source)}" unless exists
          fs.readFile sshOrLocal, options.source, 'utf8', (err, content) ->
            options.content = content unless err
            callback err
      @call ->
        if not options.engine and options.source
          extension = path.extname options.source
          switch extension
            when '.j2' then options.engine = 'nunjunks'
            when '.eco' then options.engine = 'eco'
        options.source = null
        @file options

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
