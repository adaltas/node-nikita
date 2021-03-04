---
navtitle: time_end
related:
- /action/metadata/time_start
---

# Metadata "time_end"

The `time_end` metadata stores the Unix timestamp of the time when the action is executed.

* Type: `number`
* Read-only

Its value is accessed inside the [action handler](/current/action/handler) of the next sibling action:

```js
nikita
// Call 1st action
.call(({action}) => {
  console.log)
})
// Call 2nd action
.call(({sibling}) => {
  // Print time_end of the sibling action
  console.info(sibling.metadata.time_end) // 1614765071544
})
```
