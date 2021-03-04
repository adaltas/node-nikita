---
navtitle: raw_input
related:
- /action/metadata/raw
- /action/metadata/raw_output
---

# Metadata "raw_input"

The `raw_input` metadata enables preventing arguments passed to an action to move into the ['config' property](/current/action/config). It is only used on [registering an action](/current/usages/registry).

* Type: `boolean`
* Default: `false`

For example, `config` is empty when passing arguments to the action with the metadata enabled:

```js
nikita
// Register an action
.registry.register('my_action', {
  metadata: {
    // highlight-next-line
    raw_input: true
  },
  handler: function({config}){
    // Print config
    console.info(config) // {}
}})
// Call the action
.my_action({who: 'Nikita'})
```
