
# `nikita.registry.unregister`

Expose the Registry `unregister` method as an action.

## Unregister an action

Provide the action namespace to unregister an action.

```js
const registered = await nikita
  .registry.register({
    namespace: ["an", "action"],
    action: {
      handler: () => "hello"
    }
  });
  .registry.unregister({
    namespace: ["an", "action"]
  })
  .registry.registered({
    namespace: ["an", "action"]
  })
assert(registered, false)
```
