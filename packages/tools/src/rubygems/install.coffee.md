
# `nikita.tools.gem.install`

Install a Ruby gem.

Ruby gems package a ruby library with a common layout. Inside gems are the 
following components:

- Code (including tests and supporting utilities)
- Documentation
- gemspec

## Example

Install a gem from its name and version:

```js
require('nikita')
.tools.rubygems.install({
  name: 'json',
  version: '2.1.0',
}, function(err, {status}){
  console.log( err ? err.messgage : 'Gem installed: ' + status);
});
```

Install a gem from a local file:

```js
require('nikita')
.tools.rubygems.install({
  source: '/path/to/json-2.1.0.gem',
}, function(err, {status}){
  console.log( err ? err.messgage : 'Gem installed: ' + status);
});
```

Install gems from a glob expressoin:

```js
require('nikita')
.tools.rubygems.install({
  source: '/path/to/*.gem',
}, function(err, {status}){
  console.log( err ? err.messgage : 'Gem installed: ' + status);
});
```

## Schema

    schema =
      type: 'object'
      properties:
        'bindir':
          type: 'string'
          description: """
          Directory where binary files are located.
          """
        'build_flags':
          type: 'string'
          description: """
          Pass flags to the compiler.
          """
        'bash':
          $ref: 'module://@nikitajs/engine/src/actions/execute#/properties/bash'
        'gem_bin':
          type: 'string'
          default: 'gem'
          description: """
          Path to the gem command.
          """
        'name':
          type: 'string'
          description: """
          Name of the gem.
          """
        'source':
          type: 'string'
          description: """
          Path to the gem package.
          """
        'target':
          type: 'string'
          description: """
          Install directory.
          """
        'version':
          type: 'string'
          description: """
          Version of the gem.
          """
      required: ['name']

## Handler

    handler = ({config, ssh}) ->
      # log message: "Entering rubygem.install", level: 'DEBUG', module: 'nikita/lib/tools/rubygem/install'
      # Global config
      config.ruby ?= {}
      config[k] ?= v for k, v of config.ruby
      gems = {}
      gems[config.name] ?= config.version
      # Get all current gems
      current_gems = {}
      {stdout} = await @execute
        cmd: """
        #{config.gem_bin} list --versions
        """
        shy: true
        bash: config.bash
      for line in utils.string.lines stdout
        continue if line.trim() is ''
        [name, version] = line.match(/(.*?)(?:$| \((?:default:\s+)?([\d\., ]+)\))/)[1..3]
        current_gems[name] = version.split(', ')
      # Make array of sources and filter
      sources = []
      if config.source
        {files} = await @fs.glob config.source
        current_filenames = []
        for name, versions of current_gems
          for version in versions
            current_filenames.push "#{name}-#{version}.gem"
        sources = files.filter (source) ->
          filename = path.basename source
          true unless filename in current_filenames
      # Filter gems
      for name, version of gems
        # Install if Gem isnt yet there
        continue unless current_gems[name]
        # Install if a version is demanded and no installed version satisfy it
        is_version_matching = current_gems[name].some (current_version) -> semver.satisfies version, current_version
        continue if version and not is_version_matching
        delete gems[name]
      # Install from sources
      if sources.length
        @execute
          cmd: (
            for source in sources
              [
                "#{config.gem_bin}"
                "install"
                "--bindir '#{config.bindir}'" if config.bindir
                "--install-dir '#{config.target}'" if config.target
                "--local '#{source}'" if source
                "--build-flags config.build_flags" if config.build_flags
              ].join ' '
            ).join '\n'
          code: [0, 2]
          bash: config.bash
      # Install from gems
      if Object.keys(gems).length
        @execute
          cmd: (
            for name, version of gems
              [
                "#{config.gem_bin}"
                "install"
                "#{name}"
                "--bindir '#{config.bindir}'" if config.bindir
                "--install-dir '#{config.target}'" if config.target
                "--version '#{version}'" if version
                "--build-flags config.build_flags" if config.build_flags
              ].join ' '
            ).join '\n'
          code: [0, 2]
          bash: config.bash

## Export

    module.exports =
      handler: handler
      metadata:
        global: 'ruby'
      schema: schema

## Dependencies

    path = require 'path'
    semver = require 'semver'
    utils = require '@nikitajs/engine/src/utils'
