
# `nikita.tools.gsettings`

GSettings configuration tool.

## Example

```js
const {$status} = await nikita.tools.gsettings({
  properties: {
    'org.gnome.desktop.input-sources': {
      'xkb-config': '[\'ctrl:swap_lalt_lctl\']'
    }
  }
})
console.info(`Property was modified: ${$status}`)
```
