
# `nikita.registry.register`

Expose the Registry `register` method as an action.

## Single action

An action is registered by providing its namespace and its definition

```js
const result = await nikita
  .registry.register(["an", "action"], {
    handler: () => "hello"
  });
  .an.action()
assert(result, "hello")
```

## Multiple actions

Multiple actions are registered by providing an object where keys define the action's namespaces.

```js
const action = await nikita
  .registry.register({
    "an": {
      "action": () => 'an action'
    },
    "another": {
      "action": () => 'another action'
    },
  })
  .an.action();
assert(result, "an action")
```
