
# `nikita.file.render`

Render a template file. More templating engine could be added on demand. The
following templating engines are integrated:

* [Handlebars](https://handlebarsjs.com/)

If target is a callback, it will be called with the generated content as
its first argument.   

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Value is true if rendered file was created or modified.   

## Rendering with Nunjucks

```js
require('nikita')
.file.render({
  source: './some/a_template.j2',
  target: '/tmp/a_file',
  context: {
    username: 'a_user'
  }
}, function(err, {status}){
  console.log(err ? err.message : 'File rendered: ' + status);
});
```

## On config

    on_action = ({config}) ->
      # Validate parameters
      config.encoding ?= 'utf8'
      throw Error 'Required option: source or content' unless config.source or config.content
      # Extension
      if not config.engine and config.source
        extension = path.extname config.source
        switch extension
          when '.hbs' then config.engine = 'handlebars'
          else throw Error "Invalid Option: extension '#{extension}' is not supported"

## Schema

    schema =
      type: 'object'
      properties:
        'content':
          $ref: 'module://@nikitajs/file/src/index#/properties/content'
        'context':
          $ref: 'module://@nikitajs/file/src/index#/properties/context'
        'engine':
          $ref: 'module://@nikitajs/file/src/index#/properties/engine'
        'gid':
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chown#/properties/gid'
        'mode':
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chmod#/properties/mode'
        'local':
          $ref: 'module://@nikitajs/file/src/index#/properties/local'
        'source':
          $ref: 'module://@nikitajs/file/src/index#/properties/source'
        'target':
          $ref: 'module://@nikitajs/file/src/index#/properties/target'
        'uid':
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chown#/properties/uid'
      required: ['target', 'context']

## Handler

    handler = ({config, log}) ->
      log message: "Entering file.render", level: 'DEBUG', module: 'nikita/lib/file/render'
      # Read source
      if config.source
        data = await @fs.base.readFile
          ssh: if config.local then false else config.ssh
          sudo: if config.local then false else config.sudo
          target: config.source
          encoding: config.encoding
        if data?
          config.source = undefined
          config.content = data
      @file config
      {}

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema

## Dependencies

    path = require 'path'
