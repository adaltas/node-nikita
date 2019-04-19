
# `nikita.tools.dconf`

dconf is a low-level configuration system and settings management used by
Gnome. It is a replacemet of gconf, replacing its XML based database with a
BLOB based database.

## Options

* `properties` (object)
  Name of the module.

## Example
```javascript
require('nikita').tools.dconf({ properties: 
  {'/org/gnome/desktop/datetime/automatic-timezone': 'true'} });
```

## Note

Run the command "dconf-editor" to navigate the database with a UI.

## Source Code

    module.exports = ({options}) ->
      options.properties = options.argument if options.argument?
      options.properties ?= {}
      for key, value of options.properties
        @system.execute """
        dconf read #{key} | grep -x "#{value}" && exit 3
        dconf write #{key} "#{value}"
        """, code_skipped: 3
