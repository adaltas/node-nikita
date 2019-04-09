
# `nikita.file.cson`

## Options

* `backup` (string|boolean)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `content`   
  Object to stringify.   
* `target`   
  File path where to write content to or a callback.   
* `merge`   
  Read the target if it exists and merge its content.   

## Callback parameters

* `err`   
  Error object if any.   
* `written`   
  Number of written actions with modifications.   

## Example

```js
require('nikita')
.file.yaml({
  content: {
    'my_key': 'my value'
  },
  target: '/tmp/my_file'
}, function(err, {status}){
  console.log(err ? err.message : 'Content was updated: ' + status);
});
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering file.yaml", level: 'DEBUG', module: 'nikita/lib/file/yaml'
      # SSH connection
      ssh = @ssh options.ssh
      # Options
      options.line_width ?= 160
      options.clean ?= true
      options.encoding ?= 'utf8'
      # Validate parameters
      throw Error 'Required Option: content' unless options.content
      throw Error 'Required Option: target' unless options.target
      # Start real work
      @call
        if: options.merge
      , ->
        @log message: "Get Target Content", level: 'DEBUG', module: 'nikita/lib/file/cson'
        @fs.readFile
          target: options.target
          encoding: options.encoding
          relax: true
        , (err, {data}) ->
          # File does not exists, this is ok, there is simply nothing to merge
          if err?.code is 'ENOENT'
            @log message: "No Target To Merged", level: 'DEBUG', module: 'nikita/lib/file/cson'
            return
          throw err if err
          try
            data = season.parse data
            options.content = merge data, options.content
            @log message: "Target Merged", level: 'DEBUG', module: 'nikita/lib/file/cson'
          catch err
            # Maybe change error message with sth like "Failed to parse..."
            throw err
      @call ->
        @log message: "Serialize Content", level: 'DEBUG', module: 'nikita/lib/file/cson'
        @file
          content: season.stringify options.content
          target: options.target
          backup: options.backup

## Dependencies

    {merge} = require 'mixme'
    season = require 'season'

## Resources

[season]: https://www.npmjs.com/package/season
