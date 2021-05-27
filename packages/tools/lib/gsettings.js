// Generated by CoffeeScript 2.5.1
// # `nikita.tools.gsettings`

// GSettings configuration tool.

// ## Example

// ```js
// const {$status} = await nikita.tools.gsettings({
//   properties: {
//     'org.gnome.desktop.input-sources': 'xkb-config': '[\'ctrl:swap_lalt_lctl\']'
//   }
// })
// console.log(`Property was modified: ${$status}`)
// ```

// ## Schema definitions
var definitions, handler;

definitions = {
  config: {
    type: 'object',
    properties: {
      'properties': {
        type: 'object',
        description: `List of properties to set.`
      }
    }
  }
};

// ## Handler
handler = async function({config}) {
  var key, path, properties, ref, results, value;
  if (config.argument != null) {
    config.properties = config.argument;
  }
  if (config.properties == null) {
    config.properties = {};
  }
  ref = config.properties;
  results = [];
  for (path in ref) {
    properties = ref[path];
    results.push((await (async function() {
      var results1;
      results1 = [];
      for (key in properties) {
        value = properties[key];
        results1.push((await this.execute(`gsettings get ${path} ${key} | grep -x "${value}" && exit 3
gsettings set ${path} ${key} "${value}"`, {
          code_skipped: 3
        })));
      }
      return results1;
    }).call(this)));
  }
  return results;
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    definitions: definitions
  }
};
