
# `nikita.file.ini`

Write an object as .ini file. Note, we are internally using the [ini] module.
However, there is a subtle difference. Any key provided with value of 
`undefined` or `null` will be disregarded. Within a `merge`, it get more
prowerfull and tricky: the original value will be kept if `undefined` is
provided while the value will be removed if `null` is provided.

The `file.ini` function rely on the `file` function and accept all of its
configuration. It introduces the `merge` property which instruct to read the
target file if it exists and merge its parsed object with the one
provided in the `content` option.

## Options `stringify`   

Available values for the `stringify` option are:

* `stringify`
  Default, implemented by `require('nikita/file/lib/utils/ini').stringify`

The default stringify function accepts:

* `separator` (string)   
  Characteres used to separate keys from values; default to " : ".

## Output

* `$status`   
  Indicate a change in the target file.

## Example

```js
const {$status} = await nikita.file.ini({
  content: {
    'my_key': 'my value'
  },
  target: '/tmp/my_file'
})
console.info(`Content was updated: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'backup':
            oneOf: [
              type: 'string'
            ,
              typeof: 'function'
            ]
            description: '''
            Create a backup, append a provided string to the filename extension or
            a timestamp if value is not a string, only apply if the target file
            exists and is modified.
            '''
          'clean':
            type: 'boolean'
            default: true
            description: '''
            Remove all the lines whithout a key and a value, default to "true".
            '''
          'content':
            type: 'object'
            default: {}
            description: '''
            Object to stringify.
            '''
          'eol':
            type: 'string'
            description: '''
            Characters for line delimiter, usage depends on the stringify option,
            with  the default stringify option, default to unix style if executed
            remotely  (SSH) or to the platform if executed locally ("\r\n for
            windows",  "\n" otherwise). The name stands for End Of Line.
            '''
          'encoding':
            $ref: 'module://@nikitajs/file/src/ini/read#/definitions/config/properties/encoding'
            default: 'utf8'
          'escape':
            type: 'boolean'
            default: true
            description: '''
            Escape the section's header title replace '.' by '\.'; "true" by
            default.
            '''
          'gid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/gid'
          'local':
            type: 'boolean'
            description: '''
            Read the source file locally if it exists.
            '''
          'merge':
            type: 'boolean'
            description: '''
            Read the target if it exists and merge its content.
            '''
          'mode':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/mode'
          'parse':
            $ref: 'module://@nikitajs/file/src/ini/read#/definitions/config/properties/parse'
          'stringify':
            typeof: 'function'
            description: '''
            User-defined function to stringify the content to ini format, default
            to `require('ini').stringify`, see
            'nikita.file.utils.ini.stringify\_brackets\_then_curly' for an
            example.
            '''
          'source':
            $ref: 'module://@nikitajs/file/src/ini/read#/definitions/config/properties/target'
            description: '''
            Path to a ini file providing default options; lower precedence than
            the content object; may be used conjointly with the local option;
            optional, use should_exists to enforce its presence.
            '''
          'target':
            type: 'string'
            description: '''
            File path where to write content to or a callback.
            '''
          'uid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/uid'
        required: ['content', 'target']

## Handler

    handler = ({config, tools: {log}}) ->
      org_props = {}
      default_props = {}
      parse = config.parse or utils.ini.parse
      # Original properties
      try
        {data} = await @fs.base.readFile
          target: config.target
          encoding: config.encoding
        org_props = parse data, config
      catch err
        throw err unless err.code is 'NIKITA_FS_CRS_TARGET_ENOENT'
      # Default properties
      try if config.source
        {data} = await @fs.base.readFile
          $if: config.source
          $ssh: false if config.local
          $sudo: false if config.local
          target: config.source
          encoding: config.encoding
        content = utils.object.clean config.content, true
        config.content = merge parse(data, config), config.content
      catch err
        throw err unless err.code is 'NIKITA_FS_CRS_TARGET_ENOENT'
      # Merge
      if config.merge
        config.content = merge org_props, config.content
        log message: "Get content for merge", level: 'DEBUG'
      if config.clean
        log message: "Clean content", level: 'INFO'
        utils.object.clean config.content
      log message: "Serialize content", level: 'DEBUG'
      stringify = config.stringify or utils.ini.stringify
      await @file
        target: config.target
        content: stringify config.content, config
        backup: config.backup
        diff: config.diff
        eof: config.eof
        gid: config.gid
        uid: config.uid
        mode: config.mode

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    utils = require '../utils'
    {merge} = require 'mixme'
