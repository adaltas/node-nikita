---
navtitle: log
related:
- /action/tools/log
---

# Metadata "log"

The `log` metadata disables [logging](/current/usage/logging_debugging) in an action or call a function every time the [`tools.log`](/current/action/tools/log) function is called.

* Type: `boolean|function`
* Default: `""`

When its value is `false`, it disables logging in an action and all its child actions.
When it is a function, the function is called every time the `tools.log` function is called. The [`log` object](/current/action/tools/log#log-object), [`config`](/current/action/config) and [`metadata`](/current/action/metadata) of an action are available as properties of the first argument passed to the function.

The value of the `log` metadata of a parent action is propagated to all its child actions.

## Usage

To disable logging, pass `false` to the metadata when calling an action:

```js
nikita
// Disable logging in an action and all its children
.call({
  metadata: {
    // highlight-next-line
    log: false
  }
}, function() {
  // Call a child action without logging
  this.execute('whoami')
})
```

To call a function on each `tools.log` call, pass it to the metadata:

```js
nikita
// Call an action
.call({
  metadata: {
    // Declare a function
    // highlight-range{1-6}
    log: ({log, config, metadata}) => {
      // Print properties
      console.info('log', log)
      console.info('config', config)
      console.info('metadata', metadata)
    }
  }
}, ({tools}) => {
  // Emmit a log object
  tools.log('My log message')
})
```
