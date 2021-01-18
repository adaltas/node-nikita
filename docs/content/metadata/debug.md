---
title: Metadata "debug"
redirects:
- /options/debug/
---

# Metadata "debug" (boolean, optional, false)

The "debug" option print detailed logs to the standard error output (`stderr`). It provides a quick and convenient solution to understand the various actions called, what they do and in which order.

The information thrown by the "debug" option is similar to the output of the [logging](/usages/loging_debugging/) facilities. So when shall debugging be used versus logging? The "debug" option is for developers who wish to punctually see on their shell what going on inside. The logging facilities are meant to be constantly activated.

## Activating debugging

Activating debugging is easy, simply pass the "debug" option with a value set as `true`:

```js
require('nikita')
.file.touch({
  target: '/tmp/a_file',
  debug: true
})
```

Of course, it is possible to activate debugging to the overall Nikita session by passing the option globally at session creation:

```js
require('nikita')
({
  debug: true
})
.file.touch({
  target: '/tmp/a_file'
})
```

## Redirecting output to stdout

Set the value to "stdout" if you wish to print debugging information to the standart output (`stdout`):

```js
require('nikita')
.file.touch({
  target: '/tmp/a_file',
  debug: 'stdout'
})
```
