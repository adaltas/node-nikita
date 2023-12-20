
# `nikita.registry.unregister`

Expose the Registry `unregister` method as an action.

## Unregister an action

Provide the action namespace to unregister an action.

```js
const registered = await nikita
  .registry.register(["an", "action"], {
    handler: () => "hello"
  });
  .registry.unregister(["an", "action"])
  .registry.registered(["an", "action"])
assert(registered, false)
```
