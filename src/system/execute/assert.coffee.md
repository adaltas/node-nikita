
# `nikita.system.execute.assert(options)`

Assert a shell command.

## Options

* `cmd`   
  String, Object or array; Command to execute.
* `not` (boolean)   
  Negates the validation.   

## Assert a command stdout

```javascript
nikita.system.execute({
  cmd: 'echo hello'
  assert: 'hello'
}, function(err){
  console.log(err || 'ok');
});
```

## Source Code

    module.exports = (options) ->
      @call
        if: options.content? and (typeof options.content is 'string' or Buffer.isBuffer options.content)
      , ->
        @system.execute options.cmd, (err, _, stdout) ->
          throw err if err
          unless options.not
            unless stdout is options.content
              options.error ?= "Invalid content"
              err = Error options.error
          else
            if stdout is options.content
              options.error ?= "Unexpected content"
              err = Error options.error
          throw err if err
      @call
        if: options.content? and options.content instanceof RegExp
      , ->
        @system.execute options.cmd, (err, _, stdout) ->
          throw err if err
          unless options.not
            unless options.content.test stdout 
              options.error ?= "Invalid content match"
              err = Error options.error
          else
            if options.content.test stdout
              options.error ?= "Unexpected content match"
              err = Error options.error
          throw err if err
