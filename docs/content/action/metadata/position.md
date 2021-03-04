---
navtitle: position
related:
- /action/metadata/depth
- /action/metadata/index
---

# Metadata "position"

The `position` metadata indicates the position of the action in the Nikita session tree.

* Type: `array`
* Read-only

It is an array of numbers in which the value of the number denotes the [index](/current/metadata/index/) of the action among sibling actions, and the index of it denotes the [action depth level](/current/metadata/depth/) in the session tree.

It is primarily used internally in functionality such as [logging and debugging](/current/usages/logging_debugging).

## Usage

Its value is accessed inside the [action handler](/current/action/handler).

```js
nikita
// Call an action
.call(function({metadata: {position}}) {
  // Print the value
  console.info(position) // [ 0, 0 ]
})
```
