---
navtitle: events
---

# Tool "events"

Nikita provides a facility to publish and listen to events. It creates an instance of the [EventEmitter](https://nodejs.org/api/events.html) class of the [Node.js events](https://nodejs.org/api/events.html) module. The instance is available inside the Nikita action handler as the `tools.events` property. 

## Usage

You can publish events by calling the `tools.events.emit(eventName[, ...args])` function and subscribe to those events by registering listeners with the `tools.events.on(eventName, listener)` function. The following example demonstrates it:

```js
nikita(({tools}) => {
  // Register a listener
  tools.events.on('my_event', (name) => {
    console.info(`I am ${name}`)
  })
  // Emit an event
  tools.events.emit('my_event', 'Nikita')
})
// Outputs with "I am Nikita"
```

Most of the time when writing your custom action handlers, you want to provide context information to the event listener such as the module name where the event occurred, the logging level, etc. Instead of calling `tools.events.emit`, you are encouraged to use the [`tools.log`](/current/action/tools/log) function which validates and enriches the context object, and uses native Node.js `emit` internally.

## Available events

Certain events are automatically emitted. They correspond to the action lifecycle and provide notifications on the internal state of the Nikita session:

- `nikita:action:start`   
  It is emitted right before an action's handler execution.
- `nikita:action:end`   
  It is emitted after the action handler has completed, whether it failed or was successful.
- `nikita:resolved`   
  It is emitted once at a Nikita session when all action handlers have completed successfully.
- `nikita:rejected`   
  It is emitted once at a Nikita session when an action's handler has failed.

Some functionality like [logging and debugging](/current/usage/logging_debugging) also relies on the event facility and emits following events:

- `diff`   
  It represents content modification. Used for example by the `file` action.
- `stderr`   
  It is an input reader receiving stderr content. Used for example by the `nikita.execute` action to send stderr output from the executed command.
- `stderr_stream`   
  It is a stream input reader receiving stderr content. Used for example by the `nikita.execute` action to send stderr output from the executed command.
- `stdin`   
  It represents some stdin content. Used for example by the `nikita.execute` action to provide the script being executed.
- `stdout`   
  It is an input reader receiving stdout content. Used for example by the `nikita.execute` action to send stdout output from the executed command.
- `stdout_stream`   
  It is a stream input reader receiving stdout content. Used for example by the `nikita.execute` action to send stdout output from the executed command.
- `text`   
  It is the default event when the `tools.log()` function is called.
