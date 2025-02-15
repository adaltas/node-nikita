/*
# Registry

Management facility to register and unregister actions.
*/

// Dependencies
import path from "node:path";
import { is_object, merge, mutate } from "mixme";

// Register all functions
const create = function ({ chain, on_register, parent, plugins } = {}) {
  const store = {};
  const obj = {
    chain: chain,
  };
  /*

  ## Create

  Create a new registry.

  Options include:

  * `chain`
    Default object to return, used by `register`, `deprecate` and `unregister`.
    Could be used to provide a chained style API.
  * `on_register`
    User function called on action registration. Takes two arguments: the action
    name and the action itself.
  * `parent`
    Parent registry.
  
   */
  obj.create = function (options = {}) {
    // Inherit options from parent
    options = merge(
      {
        chain: obj.chain,
        on_register: on_register,
        parent: parent,
      },
      options,
    );
    // Create the child registry
    return create(options);
  };
  /*
  
  ## load

  Load an action from the module name.
  
  */
  obj.load = async function (module) {
    if (typeof module !== "string") {
      throw Error(
        `Invalid Argument: module must be a string, got ${module.toString()}`,
      );
    }
    if (module.startsWith(".")) {
      module = path.resolve(process.cwd(), module);
    }
    let action = (await import(module)).default;
    if (typeof action === "function") {
      action = {
        handler: action,
      };
    }
    action.metadata ??= {};
    action.metadata.module = module;
    return action;
  };
  /*

  ## Get

  Retrieve an action by name or list all actions if the namespace is not provided.
  It will also search the action in the parent registries.

  The signature is `get([namespace][, options])`.

  Options include:

  * `flatten`
    Return an array of action instead of a hierarchical tree
  * `deprecate`
    Include deprecated actions
  * `normalize` (boolean, true)
    Call the 'nikita:registry:normalize' hook.

   */
  obj.get = async function (namespace, options) {
    if (arguments.length === 1 && is_object(arguments[0])) {
      options = namespace;
      namespace = null;
    }
    options ??= {};
    options.normalize ??= true;
    // Return multiple actions
    if (!namespace) {
      // Flatten result
      if (options.flatten) {
        const actions = [];
        const walk = function (store, keys) {
          const results = [];
          for (const k in store) {
            const v = store[k];
            if (k === "") {
              if (v.metadata?.deprecate && !options.deprecate) {
                continue;
              }
              v.namespace = keys;
              results.push(actions.push(merge(v)));
            } else {
              results.push(walk(v, [...keys, k]));
            }
          }
          return results;
        };
        walk(store, []);
        if (!parent) {
          return actions;
        } else {
          return [...(await parent.get(options)), ...actions];
        }
      } else {
        // Tree result
        const walk = function (store, keys) {
          const res = {};
          for (const k in store) {
            let v = store[k];
            if (k === "") {
              if (v.metadata?.deprecate && !options.deprecate) {
                continue;
              }
              res[k] = merge(v);
            } else {
              v = walk(v, [...keys, k]);
              if (Object.values(v).length !== 0) {
                res[k] = v;
              }
            }
          }
          return res;
        };
        const actions = walk(store, []);
        if (!parent) {
          return actions;
        } else {
          return merge(await parent.get(options), actions);
        }
      }
    }
    if (typeof namespace === "string") {
      // Return one action
      namespace = [namespace];
    }
    let action = null;
    // Search for action in the current registry
    let child_store = store;
    const namespaceTemp = namespace.concat([""]);
    for (let i = 0; i < namespaceTemp.length; i++) {
      const n = namespaceTemp[i];
      if (!child_store[n]) {
        break;
      }
      if (child_store[n] && i === namespace.length) {
        action = child_store[n];
        break;
      }
      child_store = child_store[n];
    }
    // Action is not found, search in the parent registry
    if (!action && parent) {
      action = await parent.get(namespace, {
        ...options,
        normalize: false,
      });
    }
    if (action == null) {
      return null;
    }
    if (!options.normalize) {
      // Return the raw action, without normalizing it
      return action;
    }
    action = merge(action);
    if (plugins) {
      // Hook attented to modify an action returned by the registry
      return await plugins.call({
        name: "nikita:registry:normalize",
        args: action,
        handler: (action) => action,
      });
    } else {
      return action;
    }
  };
  /*

  ## Register

  Register new actions.

  With an action path:

  ```js
  nikita.register('first_action', 'path/to/action')
  nikita.first_action(options);
  ```

  With a namespace and an action path:

  ```js
  nikita.register(['second', 'action'], 'path/to/action')
  nikita.second.action(options);
  ```

  With an action object:

  ```js
  nikita.register('third_action', {
    metadata: relax: true,
    handler: function(options){ console.info(options.relax) }
  })
  nikita.third_action(options);
  ```

  With a namespace and an action object:

  ```js
  nikita.register(['fourth', 'action'], {
    metadata: relax: true,
    handler: function(options){ console.info(options.relax) }
  })
  nikita.fourth.action(options);
  ```

  Multiple actions:

  ```js
  nikita.register({
    'fifth_action': 'path/to/action'
    'sixth': {
      '': 'path/to/sixth',
      'action': : 'path/to/sixth/actkon'
    }
  })
  nikita
  .fifth_action(options);
  .sixth(options);
  .sixth.action(options);
  ```

   */
  obj.register = async function (namespace, action) {
    if (typeof namespace === "string") {
      namespace = [namespace];
    }
    if (Array.isArray(namespace)) {
      if (action === void 0) {
        return obj.chain || obj;
      }
      if (typeof action === "string") {
        action = await obj.load(action);
      } else if (typeof action === "function") {
        action = {
          handler: action,
        };
      }
      let child_store = store;
      for (let i = 0; i < namespace.length; i++) {
        const property = namespace[i];
        child_store[property] ??= {};
        child_store = child_store[property];
      }
      child_store[""] = action;
      if (on_register) {
        await on_register(namespace, action);
      }
    } else {
      const walk = async function (namespace, store) {
        for (const k in store) {
          action = store[k];
          if (
            k !== "" &&
            action &&
            typeof action === "object" &&
            !Array.isArray(action) &&
            !(action.handler || action.module)
          ) {
            namespace.push(k);
            await walk(namespace, action);
          } else {
            if (typeof action === "string") {
              action = await obj.load(action);
            } else if (typeof action === "function") {
              action = {
                handler: action,
              };
            }
            namespace.push(k);
            store[k] =
              k === "" ? action : (
                {
                  "": action,
                }
              );
            if (on_register) {
              await on_register(namespace, action);
            }
          }
        }
      };
      await walk([], namespace);
      mutate(store, namespace);
    }
    return obj.chain || obj;
  };
  /*

  ## Deprecate

  `nikita.deprecate(old_function, [new_function], action)`

  Deprecate an old or renamed action. Internally, it leverages
  [Node.js `util.deprecate`](https://nodejs.org/api/util.html#util_util_deprecate_function_string).

  For example:

  ```js
  nikita.deprecate('old_function', 'new_function', -> 'my_function')
  nikita.old_function()
   * Print
   * (node:75923) DeprecationWarning: old_function is deprecated, use new_function
  ```

   */
  obj.deprecate = async function (old_name, new_name, action) {
    let handler;
    if (arguments.length === 2) {
      handler = new_name;
      new_name = null;
    }
    if (typeof action === "string") {
      action = await obj.load(action);
    }
    if (typeof handler === "function") {
      action = {
        handler: handler,
      };
    }
    action.metadata ??= {};
    action.metadata.deprecate = new_name;
    if (typeof action.module === "string") {
      action.metadata.deprecate ??= action.module;
    }
    action.metadata.deprecate ??= true;
    obj.register(old_name, action);
    return obj.chain || obj;
  };
  /*

   * Registered

  Test if a function is registered or not.

  Options:

  * `local` (boolean)
    Search action in the parent registries.
  * `partial` (boolean)
    Return true if name match a namespace and not a leaf action.

   */
  obj.registered = function (name, options = {}) {
    if (typeof name === "string") {
      name = [name];
    }
    if (!options.local && parent && parent.registered(name, options)) {
      return true;
    }
    let child_store = store;
    for (let i = 0; i < name.length; i++) {
      const n = name[i];
      if (
        child_store[n] == null ||
        !Object.prototype.propertyIsEnumerable.call(child_store, n)
      ) {
        return false;
      }
      if (options.partial && child_store[n] && i === name.length - 1) {
        return true;
      }
      if (child_store[n][""] && i === name.length - 1) {
        return true;
      }
      child_store = child_store[n];
    }
    return false;
  };
  /*

  ## Unregister

  Remove an action from registry.

   */
  obj.unregister = function (name) {
    if (typeof name === "string") {
      name = [name];
    }
    let child_store = store;
    for (let i = 0; i < name.length; i++) {
      const n = name[i];
      if (i === name.length - 1) {
        delete child_store[n];
      }
      child_store = child_store[n];
      if (!child_store) {
        return obj.chain || obj;
      }
    }
    return obj.chain || obj;
  };
  return obj;
};

export default create();
