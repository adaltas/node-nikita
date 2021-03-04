---
navtitle: time_start
related:
- /action/metadata/time_end
---

# Metadata "time_start"

The `time_start` metadata stores the Unix timestamp of the time when the action is executed.

* Type: `number`
* Read-only

Its value is accessed inside the [action handler](/current/action/handler).

```js
nikita
// Call an action
.call(({metadata: {time_start}}) => {
  // Print timestamp
  console.info(time_start) // 1614763528497
})
```
