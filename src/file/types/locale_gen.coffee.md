
`nikita.file.types.locale_gen`

Update the locale definition file located in "/etc/locale.gen".

## Options

*   `rootdir` (string)   
    Path to the mount point corresponding to the root directory, optional.   
*   `generate` (string)   
    Run `locale-gen` if target was modified.   
*   `locales` (string)   
    List of supported locales, required.   
*   `target` (string)   
    File to write, default to "/etc/locale.gen".   

## Example

```javascript
require('nikita').file.types.locale_gen({
  target: '/etc/locale.gen',
  rootdir: '/mnt',
  locales: ['fr_FR.UTF-8', 'en_US.UTF-8'],
  locale: 'en_US.UTF-8'
})
```

    module.exports = (options) ->
      @log message: "Entering file.types.local_gen", level: 'DEBUG', module: 'nikita/lib/file/types/local_gen'
      # Options
      options.target ?= '/etc/locale.gen'
      options.target = "#{path.join options.rootdir, options.target}" if options.rootdir
      # Write configuration
      @call (_, callback) ->
        @fs.readFile ssh: options.ssh, target: options.target, encoding: 'ascii', (err, {data}) ->
          return callback err if err
          status = false
          locales = data.split '\n'
          for locale, i in locales
            if match = /^#([\w_\-\.]+)($| .+$)/.exec locale
              if match[1] in options.locales
                locales[i] = match[1]+match[2]
                status = true
            if match = /^([\w_\-\.]+)($| .+$)/.exec locale
              if match[1] not in options.locales
                locales[i] = '#'+match[1]+match[2]
                status = true
          return callback() unless status
          data = locales.join '\n'
          @fs.writeFile ssh: options.ssh, target: options.target, content: data, (err) ->
            callback err, true
      # Reload configuration
      @system.execute
        if: -> options.generate and @status -1
        cmd: "locale-gen"

## Dependencies

    path = require 'path'
