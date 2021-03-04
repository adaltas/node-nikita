---
navtitle: log
related:
- /action/tools/events
- /action/output/log
- /action/metadata/log
---

# Tool "log"

The `log` tool is a function to share information about the state of Nikita's actions.

It is possible to listen to the emitted log objects and to use their information for [logging or debugging](/current/usage/logging_debugging). The [`log.cli`](/current/actions/log/cli) action prints the status of the Nikita session to the console. The [`log.md`](/current/actions/log/md) action dumps the logs into a file using the [Markdown](https://en.wikipedia.org/wiki/Markdown) format.

Emitted log objects are also available in the [`logs` array](/current/action/output/logs) of the [action output](/current/action/output).

It is based on the [Node.js events](https://nodejs.org/api/events.html) module and it internally uses the [`tools.events.emit`](/current/action/tools/events) function. It is available inside the [action handler](/current/action/handler) as the `tools.log` property of the first argument.

## Log object

The log object contains the information about the state of an action and consist of the following properties:

- `depth`   
  A depth level of the action in a hierarchical tree of the Nikita session honored from the [`depth` metadata](/current/action/metadata/depth).
- `index`   
  A position of the action among siblings honored from the [`index` metadata](/current/action/metadata/index).
- `filename`   
  A full path to the file where the event is emitted.
- `file`   
  A filename where the event is emitted.
- `level`   
  A log level, default is `INFO`. Suggested values are `INFO`, `WARN`, `ERROR`, `DEBUG`.
- `line`   
  A line number where the event is emitted.
- `message`   
  A user message.
- `module`   
  A path to the Node.js module of the registered action honored from the [`module` metadata](/current/action/metadata/module).
- `namespace`   
  A list of names of the action from root to a child. It is honored from the [`module` metadata](/current/action/metadata/module).
- `position`   
  A list of indices corresponding to the position in the hierarchical tree of the Nikita session. It is honored from the [`position` metadata](/current/action/metadata/position).
- `time`   
  A Unix timestamp of when the event is emitted.
- `type`   
  A [Node.js event](https://nodejs.org/api/events.html) name, default to `text`.

## Usage

To emit an event, call the `tools.log` function passing properties to the argument object:

```js
nikita
// Call an action
.call(({tools}) => {
  // Emit an event
  tools.log({
    level: 'DEBUG',
    message: 'Some message'
  })
})
```

To pass only the `message` property, call it with a string argument:

```js
nikita
// Call an action
.call(({tools}) => {
  // Emit an event
  tools.log('Some message')
})
```
