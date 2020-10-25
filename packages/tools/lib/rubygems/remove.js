// Generated by CoffeeScript 2.5.1
// # `nikita.tools.gem.remove`

// Remove a Ruby gem.

// Ruby Gems package a ruby library with a common layout. Inside gems are the 
// following components:

// - Code (including tests and supporting utilities)
// - Documentation
// - gemspec   

// ## Callback parameters

// * `err`   
//   Error object if any.   
// * `status`   
//   Indicate if a gem was removed.   

// ## Ruby behavior

// Ruby place global gems inside "/usr/share/gems/gems" and user gems are by 
// default installed inside "/usr/local/share/gems".

// Any attempt to remove a gem installed globally and not in the user repository 
// will result with the error "{gem} is not installed in GEM_HOME, try: gem 
// uninstall -i /usr/share/gems json"

// ## Schema
var handler, schema;

schema = {
  type: 'object',
  properties: {
    'gem_bin': {
      type: 'string',
      default: 'gem',
      description: `Path to the gem command.`
    },
    'name': {
      type: 'string',
      description: `Name of the gem, required.`
    },
    'version': {
      type: 'string',
      description: `Version of the gem.`
    }
  },
  required: ['name']
};

// ## Handler
handler = function({config}) {
  var gems, k, ref, v, version;
  // log message: "Entering rubygem.remove", level: 'DEBUG', module: 'nikita/lib/tools/rubygem/remove'
  // Global config
  if (config.ruby == null) {
    config.ruby = {};
  }
  ref = config.ruby;
  for (k in ref) {
    v = ref[k];
    if (config[k] == null) {
      config[k] = v;
    }
  }
  if (config.gem_bin == null) {
    config.gem_bin = 'gem';
  }
  version = config.version ? `-v ${config.version}` : '-a';
  gems = null;
  return this.execute({
    cmd: `${config.gem_bin} list -i ${config.name} || exit 3
${config.gem_bin} uninstall ${config.name} ${version}`,
    code_skipped: 3,
    bash: config.bash
  });
};

// ## Export
module.exports = {
  handler: handler,
  metadata: {
    global: 'ruby'
  },
  schema: schema
};
