
# `nikita.registry.get`

Expose the Registry `get` method as an action.

## All actions

Calling the action without any arguments return all the registered actions.

```js
const actions = await nikita.registry.get();
```

## Single action

Calling the action with its registered name return the action.

```js
const action = await nikita
  .registry.register({
    namespace: ['an', 'action'],
    action: {
      $handler: () => true
    }
  })
  .registry.get({
    namespace: ['an', 'action']
  });
```
