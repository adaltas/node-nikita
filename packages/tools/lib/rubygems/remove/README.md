
# `nikita.tools.rubygems.remove`

Remove a Ruby gem.

## Output

* `$status`   
  Indicate if a gem was removed.

## Ruby behavior

Ruby place global gems inside "/usr/share/gems/gems" and user gems are by 
default installed inside "/usr/local/share/gems".

Any attempt to remove a gem installed globally and not in the user repository 
will result with the error "{gem} is not installed in GEM_HOME, try: gem 
uninstall -i /usr/share/gems json"
