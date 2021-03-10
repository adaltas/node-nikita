---
navtitle: position
related:
- /action/metadata/depth
- /action/metadata/index
---

# Metadata "position"

The `position` metadata indicates the position of the action relative to its parent and sibling action. It is unique to each action.

* Type: `array`
* Read-only

It is constructed as an array of numbers. The length of the array is the number of parent actions. To each element of the array correspond the action index relative to its siblings.

It is primarily used internally in functionality such as [logging and debugging](/current/usages/logging_debugging).

## Usage

Its value is accessed inside the [action handler](/current/action/handler) as the `metadata.position` property.

```js
nikita
// Call an action
.call(function({metadata: {depth, index, position}}) {
  console.info(position)
  // Print the value `[ 0, 0 ]`
})
```

## Comparing "position" with "depth" and "index"

Since the length of the array is the number of parent actions, the length equals the [`depth` metadata property](/current/metadata/depth/) plus `1` (depth start at `0`).

Also, the last element of the array is the position of current action relative to its sibling's action. Thus, its value equals the [`index` metadata property](/current/metadata/index/).

```js
const assert = require('assert');
nikita
// Call an action
.call(function({metadata: {depth, index, position}}) {
  assert.equal(depth + 1, position.length)
  assert.equal(index, position[position.length - 1])
})
```
