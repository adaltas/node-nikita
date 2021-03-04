---
navtitle: index
related:
- /action/metadata/position
- /action/metadata/depth
---

# Metadata "index"

The `index` metadata indicates the index of the action among sibling actions in the Nikita session tree.

* Type: `number`
* Read-only

Its value is accessed inside the [action handler](/current/action/handler).

```js
nikita
// Call an action
.call(function({metadata: {index}}) {
  // Print the value
  console.info(index) // 0
})
```
