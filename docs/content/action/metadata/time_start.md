---
navtitle: time_start
related:
- /action/metadata/time_end
---

# Metadata "time_start"

The `time_start` metadata property stores the Unix timestamp at the time when the action is executed.

* Type: `number`
* Read-only

## Usage

The value is accessible inside the [action handler](/current/action/handler).

```js
nikita
// Call an action
.call(({metadata: {time_start}}) => {
  // Print timestamp
  console.info(time_start) // 1614763528497
})
```

## Introspection

You can traverse previously executed actions and print the execution time by substracting the `time_start` to `time_end`. An example with the `tools.dig` action utility is:

```js
nikita(function(){
  this.call(function(){
    this.call(function(){
      return new Promise((resolve) => {
        setTimeout(resolve, 100) // Wait a bit
      })
    })
    this.call(function(){
      return new Promise((resolve) => {
        setTimeout(resolve, 100) // Wait a bit
      })
    })
  })
  this.call(function({tools: {dig}}){
    // Note, `dig` traverse the session history
    // starting with the most recent action
    dig( ({metadata: {position, time_end, time_start}}) =>
      time_end &&
      console.log(`Action ${position.join('.')} tooks ${time_end - time_start}ms`)
    )
    // Print something like
    // Action 0.0.1 tooks 102ms
    // Action 0.0.0 tooks 107ms
    // Action 0.0 tooks 214ms
  })
})
```

The various log related actions use this information to report the action execution time.
