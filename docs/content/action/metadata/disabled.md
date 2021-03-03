---
navtitle: disabled
---

# Metadata "disabled"

The `disabled` metadata disables the action execution and all its child action.

* Type: `boolean`
* Default: `false`

To disable an action executing pass `true` to the metadata:

```js
nikita
// Call a disabled action
.call({
  metadata: {
    // highlight-next-line
    disabled: true
  }
}, () => {
  // This will not be called
  console.log('I am not printed.')
})
```
