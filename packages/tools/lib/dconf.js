// Generated by CoffeeScript 2.5.0
// # `nikita.tools.dconf`

// dconf is a low-level configuration system and settings management used by
// Gnome. It is a replacemet of gconf, replacing its XML based database with a
// BLOB based database.

// ## Options

// * `properties` (object)
//   Name of the module.

// ## Example
// ```javascript
// require('nikita').tools.dconf({ properties: 
//   {'/org/gnome/desktop/datetime/automatic-timezone': 'true'} });
// ```

// ## Note

// Run the command "dconf-editor" to navigate the database with a UI.

// ## Source Code
module.exports = function({metadata, options}) {
  var key, ref, results, value;
  if (metadata.argument != null) {
    options.properties = metadata.argument;
  }
  if (options.properties == null) {
    options.properties = {};
  }
  ref = options.properties;
  results = [];
  for (key in ref) {
    value = ref[key];
    results.push(this.system.execute(`dconf read ${key} | grep -x "${value}" && exit 3
dconf write ${key} "${value}"`, {
      code_skipped: 3
    }));
  }
  return results;
};
