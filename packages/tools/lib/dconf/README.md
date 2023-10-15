
# `nikita.tools.dconf`

dconf is a low-level configuration system and settings management used by
Gnome. It is a replacemet of gconf, replacing its XML based database with a
BLOB based database.

## Example

```js
const {$status} = await nikita.tools.dconf({
  properties: {
    '/org/gnome/desktop/datetime/automatic-timezone': 'true'
  }
});
console.info(`Property was modified: ${$status}`)
```

## Note

Run the command "dconf-editor" to navigate the database with a UI.
