
# `nikita.execute.assert`

Assert the execution or the output of a command.

## Configuration

All configuration properties are passed to `system.execute`.

## Assert a command succeed

```javascript
nikita.system.execute.assert({
  cmd: 'exit 0'
}, function(err){
  console.info(err || 'ok');
});
```

## Assert a command stdout

```javascript
nikita.system.execute.assert({
  cmd: 'echo hello'
  assert: 'hello'
}, function(err){
  console.info(err || 'ok');
});
```

## Hook

    on_action = ({config, metadata}) ->
      # config.cmd = metadata.argument if metadata.argument?
      config.code ?= [0] unless config.content
      config.code = [config.code] if config.code? and not Array.isArray config.code

## Schema

    schema =
      type: 'object'
      properties:
        'code':
          type: 'array'
          # default: [0]
          items:
            type: 'integer'
          description: """
          Expected exit code, activated by default unless content is provided.
          """
        'content':
          onfOf: [{type: 'string'}, {instanceof: 'Buffer'}, {instanceof: 'RegExp'}]
          description: """
          Content to match, optional.
          """
        'error':
          type: 'string'
          description: """
          The error message to throw if assert failed.
          """
        'not':
          type: 'boolean'
          default: false
          description: """
          Negates the validation.
          """
        'trim':
          type: 'boolean'
          default: false
          description: """
          Trim the expected content as well as the command output before
          matching.
          """

## Handler

    handler = ({config}) ->
      config.content = config.content.toString() if Buffer.isBuffer config.content
      config.content = config.content.trim() if config.content and config.trim
      # Command exit code
      if config.code?
        {code} = await @execute config, relax: true
        unless config.not
          unless code in config.code
            throw error 'NIKITA_EXECUTE_ASSERT_EXIT_CODE', [
              'an unexpected exit code was encountered,'
              "got #{JSON.stringify code}"
              if config.code.length is 1
              then "while expecting #{config.code}."
              else "while expecting one of #{JSON.stringify config.code}."
            ]
        else
          if code in config.code
            throw error 'NIKITA_EXECUTE_ASSERT_NOT_EXIT_CODE', [
              'an unexpected exit code was encountered,'
              "got #{JSON.stringify code}"
              if config.code.length is 1
              then "while expecting anything but #{config.code}."
              else "while expecting anything but one of #{JSON.stringify config.code}."
            ]
      # Content is a string or a buffer
      if config.content? and typeof config.content is 'string'
        res = await @execute config
        {stdout} = res
        stdout = stdout.trim() if config.trim
        unless config.not
          unless stdout is config.content
            throw error 'NIKITA_EXECUTE_ASSERT_CONTENT', [
              'the command output is not matching the content,'
              "got #{JSON.stringify stdout}"
              "while expecting to match #{JSON.stringify config.content}."
            ]
        else
          if stdout is config.content
            throw error 'NIKITA_EXECUTE_ASSERT_NOT_CONTENT', [
              'the command output is unfortunately matching the content,'
              "got #{JSON.stringify stdout}."
            ]
      # Content is a regexp
      if config.content? and regexp.is config.content
        {stdout} = await @execute config
        stdout = stdout.trim() if config.trim
        unless config.not
          unless config.content.test stdout
            throw error 'NIKITA_EXECUTE_ASSERT_CONTENT_REGEX', [
              'the command output is not matching the content regexp,'
              "got #{JSON.stringify stdout}"
              "while expecting to match #{JSON.stringify config.content}."
            ]
        else
          if config.content.test stdout
            throw error 'NIKITA_EXECUTE_ASSERT_NOT_CONTENT_REGEX', [
              'the command output is unfortunately matching the content regexp,'
              "got #{JSON.stringify stdout}"
              "matching #{JSON.stringify config.content}."
            ]

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema

## Dependencies

    error = require '../../utils/error'
    regexp = require '../../utils/regexp'
