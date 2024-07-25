
import {merge} from 'mixme';
import each from 'each';
import {plugandplay} from 'plug-and-play';
import registry from '@nikitajs/core/registry';
import contextualize from '@nikitajs/core/session/contextualize';
import utils from '@nikitajs/core/utils';

const session = function(args) {
  // Multiply arguments
  if (args.some( (arg) => Array.isArray(arg) )) {
    return each({
      flatten: true
    }, utils.array.multiply(...args).map(function(args) {
      return function() {
        return session(args);
      };
    }));
  }
  // Local schedulers to execute children and be notified on finish
  const schedulers = {
    in: each({
      concurrency: -1,
      relax: true,
    }),
    out: each({
      concurrency: 1,
      fluent: false,
      pause: true,
    }),
  };
  // Normalize arguments
  let action;
  try {
    action = contextualize({
      args: args,
      action: {
        args: args,
        config: {},
        metadata: { namespace: [] },
        hooks: {},
        scheduler: schedulers.out,
        state: {},
      }
    });
  } catch (e) {
    return Promise.reject(e)
  }
  // Initialize the plugins manager
  action.plugins = plugandplay({
    plugins: action.plugins,
    parent: action.parent?.plugins,
  });
  // Initialize the registry to manage action registration
  action.registry ??= registry.create({
    plugins: action.plugins,
    parent: action.parent?.registry ?? registry,
    on_register: async function(name, act) {
      await action.plugins.call({
        name: 'nikita:register',
        args: {
          name: name,
          action: act
        }
      });
    }
  });
  // Children namespace
  let namespace = [];
  // Catch method calls
  const on_call = function(...args) {
    let nm;
    // Extract action namespace and reset its value
    [namespace, nm] = [[], namespace];
    // Schedule the action and get the result as a promise
    if(action.scheduler.state().closed) {
      return Promise.reject(utils.error('NIKITA_SCHEDULER_CLOSED', [
        'cannot schedule new items when closed.'
      ]))
    }
    const prom = action.scheduler.call(async function() {
      args.push({
        $namespace: nm,
        $parent: action,
      })
      return session(args);
    });
    return new Proxy(prom, {
      // Fluent call of children inside a parent
      get: (target, name) => on_get(target, name, 1),
    });
  };
  // Building the namespace before calling an action
  const on_get = function(target, name, concurrency) {
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
    action.scheduler.concurrency(concurrency);
    namespace.push(name);
    return new Proxy(on_call, {
      get: (target, name) => on_get(target, name, concurrency),
    });
  };
  // Expose the action context
  action.context = new Proxy(on_call, {
    get: (target, name) => on_get(target, name, -1),
  });
  // Execute the action
  const result = new Promise(async function(resolve, reject) {
    try {
      // Hook intented to modify the current action being created
      action = await action.plugins.call({
        name: "nikita:normalize",
        args: action,
        hooks: action.hooks?.on_normalize, //  || action.hooks?.["nikita:normalize"]
        handler: (action) => action
      });
    } catch (error) {
      schedulers.out.end(error);
      return reject(error);
    }
    // Load action from registry
    if (action.metadata.namespace) {
      try{
        const action_from_registry = await action.registry.get(action.metadata.namespace);
        if(!action_from_registry && action.metadata.namespace.length !== 0){
          return reject(utils.error('ACTION_UNREGISTERED_NAMESPACE', ['no action is registered under this namespace,', `got ${JSON.stringify(action.metadata.namespace)}.`]));
        }
        // Merge the registry action with the user action properties
        for (const k in action_from_registry) {
          const v = action_from_registry[k];
          action[k] = merge(action_from_registry[k], action[k]);
        }
      }catch(err){
        return reject(err);
      }
    }
    // Switch the scheduler to register actions inside the handler
    action.scheduler = schedulers.in;
    // Hook attended to alter the execution of an action handler
    const output = action.plugins.call({
      name: 'nikita:action',
      args: action,
      hooks: action.hooks.on_action, //  || action.hooks.["nikita:action"]
      handler: function(action) {
        // Execution of an action handler
        return action.handler?.call(action.context, action);
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
        hooks: action.hooks.on_result, //  || action.hooks.["nikita:result"]
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
    get: (target, name) => on_get(target, name, 1),
  });
};

export default function(...args) {
  return session(args);
};
