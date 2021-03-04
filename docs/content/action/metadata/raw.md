---
navtitle: raw
related:
- /action/metadata/raw_input
- /action/metadata/raw_output
---

# Metadata "raw"

The `raw` metadata defines the both [`raw_input`](/current/metadata/raw_input) and [`raw_output`](/current/metadata/raw_output) metadata.

* Type: `boolean`
* Default: `false`

The following example registers an action with enabled `raw` and the handler returning the `config` object. When calling this action with some [configuration properties](/current/action/config), it returns an empty object `{}`. It doesn't move the arguments to `config` since the `raw_input` enabled, and it doesn't modify the handler return values when passing them to the output:

```js
nikita
// Register an action
.registry.register('my_action', {
  metadata: {
    // highlight-next-line
    raw: true
  },
  handler: function({config}) {
    // Handler implementation...
    // Return config
    return config
}})
.call(async function() {
  // Call the action with config
  // highlight-next-line
  const output = await this.my_action({who: 'Nikita'})
  // Print the output
  console.info(output) // {}
})
```

For the sake of comparing, a similar code example but without enabled metadata prints the following: 

```
{ who: 'Nikita', status: false, logs: [] }
```
