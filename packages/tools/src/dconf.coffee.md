
# `nikita.tools.dconf`

dconf is a low-level configuration system and settings management used by
Gnome. It is a replacemet of gconf, replacing its XML based database with a
BLOB based database.

## Example

```javascript
const {status} = await nikita.tools.dconf({
  properties: {
    '/org/gnome/desktop/datetime/automatic-timezone': 'true'
  }
});
console.info(`Property modified: ${status}`)
```

## Note

Run the command "dconf-editor" to navigate the database with a UI.

## Schema

    schema =
      type: 'object'
      properties:
        'properties':
          type: 'object'
          description: """
          Name of the module.
          """

## Source Code

    handler = ({metadata, config}) ->
      config.properties = metadata.argument if metadata.argument?
      config.properties ?= {}
      for key, value of config.properties
        @execute """
        dconf read #{key} | grep -x "#{value}" && exit 3
        dconf write #{key} "#{value}"
        """, code_skipped: 3

## Exports

    module.exports =
      handler: handler
      schema: schema
