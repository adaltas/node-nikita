
# `nikita.tools.gsettings`

GSettings configuration tool.

## Example

```js
const {status} = await nikita.tools.gsettings({
  properties: {
    'org.gnome.desktop.input-sources': 'xkb-config': '[\'ctrl:swap_lalt_lctl\']'
  }
})
console.log(`Property modified: ${status}`)
```

## Schema

    schema =
      type: 'object'
      properties:
        '':
          type: 'object'
          description: """
          """

## Handler

    handler = ({config}) ->
      config.properties = config.argument if config.argument?
      config.properties ?= {}
      for path, properties of config.properties
        for key, value of properties
          @execute """
          gsettings get #{path} #{key} | grep -x "#{value}" && exit 3
          gsettings set #{path} #{key} "#{value}"
          """, code_skipped: 3

## Exports

    module.exports =
      handler: handler
      schema: schema
