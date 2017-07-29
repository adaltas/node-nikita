
# `nikita.tools.gem.install(options, [callback])`

Install a Ruby gem.

Ruby gems package a ruby library with a common layout. Inside gems are the 
following components:

- Code (including tests and supporting utilities)
- Documentation
- gemspec

## Options

* `bindir` (string)   
  Directory where binary files are located.
* `build_flags` (string)   
  Pass flags to the compiler.
* `gem_bin` (string)   
  Path to the gem command, default to 'gem'
* `name` (string)   
  Name of the gem, required.   
* `target` (string)   
  Install directory.
* `version` (string)   
  Version of the gem.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  Indicate if a gem was installed.

## Exemples

Install a gem from its name and version:

```js
require('nikita')
.tools.rubygems.fetch({
  name: 'json',
  version: '2.1.0',
}, function(err, status){
  console.log( err ? err.messgage : 'Gem installed: ' + status);
});
```

Install a gem from a local file:

```js
require('nikita')
.tools.rubygems.fetch({
  name: 'json',
  source: '/path/to/json-2.1.0.gem',
}, function(err, status){
  console.log( err ? err.messgage : 'Gem installed: ' + status);
});
```

## Source code

    module.exports = (options) ->
      options.log message: "Entering rubygem.install", level: 'DEBUG', module: 'nikita/lib/tools/rubygem/install'
      # Global Options
      options.ruby ?= {}
      options[k] ?= v for k, v of options.ruby
      options.gem_bin ?= 'gem'
      options.gems ?= {}
      options.gems[options.name] ?= options.version if options.name
      current_gems = {}
      @system.execute
        cmd: """
        #{options.gem_bin} list --versions
        """
        shy: true
        bash: options.bash
      , (err, _, stdout) ->
        for line in string.lines stdout
          continue if line.trim() is ''
          [name, version] = line.match(/(.*?)(?:$| \((?:default:\s+)?([\d\., ]+)\))/)[1..3]
          current_gems[name] = version.split(', ')
      @call ->
        for name, version of options.gems
          # Install if Gem isnt yet there
          continue unless current_gems[name]
          # Install if a version is demanded and no installed versio satisfy it
          is_version_matching = current_gems[name].some (current_version) -> semver.satisfies version, current_version
          continue if version and not is_version_matching
          delete options.gems[name]
      @call ->
        @system.execute
          if: Object.keys(options.gems).length
          cmd: (
            for name, version of options.gems
              [
                "#{options.gem_bin}"
                "install"
                "#{options.name}"
                "--bindir '#{options.bindir}'" if options.bindir
                "--install-dir '#{options.target}'" if options.target
                "--version '#{options.version}'" if options.version and not options.source
                "--local '#{options.source}'" if options.source
                "--build-flags options.build_flags" if options.build_flags
              ].join ' '
            ).join '\n'
          code: [0, 2]
          bash: options.bash
      
## Dependencies

    semver = require 'semver'
    string = require '../../misc/string'
