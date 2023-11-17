
const {merge} = require('mixme');
const each = require('each');
const registry = require('./registry');
const {plugandplay} = require('plug-and-play');
const contextualize = require('./session/contextualize');
const normalize = require('./session/normalize');
const utils = require('./utils');

const session = function(args, options = {}) {
  // Catch calls to new actions
  let namespace = [];
  const on_call = function(...args) {
    let nm;
    // Extract action namespace and reset the state
    [namespace, nm] = [[], namespace];
    // Schedule the action and get the result as a promise
    const prom = action.scheduler.call(async function() {
      // Validate the namespace
      const child = (await action.registry.get(nm));
      if (!child) {
        return Promise.reject(utils.error('ACTION_UNREGISTERED_NAMESPACE', ['no action is registered under this namespace,', `got ${JSON.stringify(nm)}.`]));
      }
      const args_is_array = args.some(function(arg) {
        return Array.isArray(arg);
      });
      if (!args_is_array || child.metadata?.raw_input) {
        return session(args, {
          namespace: nm,
          child: child,
          parent: action
        });
      }
      // Multiply the arguments
      return each({
        flatten: true
      }, utils.array.multiply(...args).map(function(args) {
        return function() {
          return session(args, {
            namespace: nm,
            child: child,
            parent: action
          });
        };
      }));
    });
    return new Proxy(prom, {
      get: on_get
    });
  };
  // Building the namespace before calling an action
  const on_get = function(target, name) {
    // Return static properties
    if ((target[name] != null) && !action.registry.registered(name)) {
      if (typeof target[name] === 'function') {
        return target[name].bind(target);
      } else {
        return target[name];
      }
    }
    // Return the plugins instance in the root session
    if (namespace.length === 0) {
      switch (name) {
        case 'plugins':
          return action.plugins;
      }
    }
    namespace.push(name);
    return new Proxy(on_call, {
      get: on_get
    });
  };
  // Initialize the plugins manager
  options.parent = options.parent || args[0]?.$parent || undefined
  options.namespace = options.namespace || args[0]?.$namespace || undefined
  const plugins = plugandplay({
    plugins: options.plugins || args[0]?.$plugins,
    chain: new Proxy(on_call, {
      get: on_get
    }),
    parent: options.parent ? options.parent.plugins : undefined
  });
  // Normalize arguments
  let action = plugins.call_sync({
    name: 'nikita:arguments',
    args: {
      args: args,
      ...options
    },
    handler: function({args, namespace}) {
      return contextualize([
        ...args,
        {
          $namespace: namespace
        }
      ]);
    }
  });
  action.parent = options.parent;
  action.plugins = plugins;
  if (action.metadata.namespace == null) {
    action.metadata.namespace = [];
  }
  // Initialize the registry to manage action registration
  action.registry = registry.create({
    plugins: action.plugins,
    parent: action.parent ? action.parent.registry : registry,
    on_register: async function(name, act) {
      return (await action.plugins.call({
        name: 'nikita:register',
        args: {
          name: name,
          action: act
        }
      }));
    }
  });
  // Local scheduler to execute children and be notified on finish
  const schedulers = {
    in: each({
      relax: true
    }),
    out: each({
      pause: true,
      fluent: false
    })
  };
  action.scheduler = schedulers.out;
  // Expose the action context
  action.context = new Proxy(on_call, {
    get: on_get
  });
  // Execute the action
  const result = new Promise(async function(resolve, reject) {
    try {
      // Hook intented to modify the current action being created
      action = (await action.plugins.call({
        name: 'nikita:normalize',
        args: action,
        hooks: action.hooks?.on_normalize || action.on_normalize,
        handler: normalize
      }));
    } catch (error) {
      schedulers.out.end(error);
      return reject(error);
    }
    // Load action from registry
    if (action.metadata.namespace) {
      const action_from_registry = (await action.registry.get(action.metadata.namespace));
      // Merge the registry action with the user action properties
      for (const k in action_from_registry) {
        const v = action_from_registry[k];
        action[k] = merge(action_from_registry[k], action[k]);
      }
    }
    // Switch the scheduler to register actions inside the handler
    action.scheduler = schedulers.in;
    // Hook attended to alter the execution of an action handler
    const output = action.plugins.call({
      name: 'nikita:action',
      args: action,
      hooks: action.hooks.on_action,
      handler: function(action) {
        // Execution of an action handler
        return action.handler.call(action.context, action);
      }
    });
    // Ensure child actions are executed even after parent execution
    const pump = output.catch(function(err) {
      return schedulers.in.error(err);
    }).then(function() {
      return schedulers.in.end();
    });
    // Make sure the promise is resolved after the scheduler and its children
    Promise.all([output, pump]).then(async function([output]) {
      await schedulers.out.resume();
      return output;
    }).then(function(output) {
      schedulers.out.end();
      return on_result(undefined, output);
    }, function(err) {
      schedulers.out.end(err);
      return on_result(err);
    });
    // Hook to catch error and format output once all children are executed
    const on_result = function(error, output) {
      return action.plugins.call({
        name: 'nikita:result',
        args: {
          action: action,
          error: error,
          output: output
        },
        hooks: action.hooks.on_result,
        handler: function({action, error, output}) {
          if (error) {
            throw error;
          } else {
            return output;
          }
        }
      }).then(resolve, reject);
    };
  });
  result.then(function(output) {
    if (action.parent !== undefined) { return; }
    return action.plugins.call({
      name: 'nikita:resolved',
      args: {
        action: action,
        output: output
      }
    });
  }, function(err) {
    if (action.parent !== undefined) { return; }
    return action.plugins.call({
      name: 'nikita:rejected',
      args: {
        action: action,
        error: err
      }
    });
  });
  // Returning a proxified promise:
  // - new actions can be registered to it as long as the promised has not fulfilled
  // - resolve when all registered actions are fulfilled
  // - resolved with the result of handler
  return new Proxy(result, {
    get: on_get
  });
};

module.exports = function(...args) {
  return session(args);
};

module.exports.with_options = function(args, options) {
  return session(args, options);
};
