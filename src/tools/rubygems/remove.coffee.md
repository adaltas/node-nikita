
# `nikita.tools.gem.remove(options, [callback])`

Remove a Ruby gem.

Ruby Gems package a ruby library with a common layout. Inside gems are the 
following components:

- Code (including tests and supporting utilities)
- Documentation
- gemspec

## Options

* `gem_bin` (string)   
  Path to the gem command, default to 'gem'
* `name` (string)   
  Name of the gem, required.   
* `version` (string)   
  Version of the gem, default to all versions.   

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Indicate if a gem was removed.   

## Ruby behavior

Ruby place global gems inside "/usr/share/gems/gems" and user gems are by 
default installed inside "/usr/local/share/gems".

Any attempt to remove a gem installed globally and not in the user repository 
will result with the error "{gem} is not installed in GEM_HOME, try: gem 
uninstall -i /usr/share/gems json"

## Source code

    module.exports = (options) ->
      options.log message: "Entering rubygem.remove", level: 'DEBUG', module: 'nikita/lib/tools/rubygem/remove'
      options.gem_bin ?= 'gem'
      version = if options.version then "-v #{options.version}" else '-a'
      gems = null
      @system.execute
        cmd: """
        #{options.gem_bin} list -i #{options.name} || exit 3
        #{options.gem_bin} uninstall #{options.name} #{version}
        """
        code_skipped: 3
