---
navtitle: depth
related:
- /action/metadata/position
- /action/metadata/index
---

# Metadata "depth"

The `depth` metadata indicates the level number of the action in the Nikita session tree.

* Type: `number`
* Read-only

## Usage

Its value is accessed inside the [action handler](/current/action/handler).

```js
nikita
// Call parent action
.call(function() {
  // Call child action
  this.call(function({metadata: {depth}}) {
    // Print the value
    console.info(depth) // 2
  })
})
```
