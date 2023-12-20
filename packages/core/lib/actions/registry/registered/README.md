
# `nikita.registry.registered`

Expose the Registry `registered` method as an action.

## Check if an action is registered

Provide the action namespace to unregister an action.

```js
const registered = await nikita
  .registry.register(["an", "action"], {
    handler: () => "hello"
  });
  .registry.registered(["an", "action"])
assert(registered, true)
```
