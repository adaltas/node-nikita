---
title: Logging and Debugging
sort: 6
---

# Logging and Debugging

## Introduction

Nikita provides multiple mechanisms to report, dive into the logs and intercept instructions. Most of them can be instantaneously activated and you are provided with simple building blocks to quickly write your own.

## Quick debugging

While developing, you can use the ["debug" options](/metadata/debug/) to get visual and detailed information. This option [cascaded](/action/cascade/) and, as such, will be passed to every child actions.

The option can be provided directly to the action in trouble:

```javascript
require('nikita')
// Pass debug as an additional option
.system.execute({
  cmd: 'whoami',
  debug: true
})
```

Alternatively, the "debug" options can be defined globally when initializing the session:

```javascript
nikita = require('nikita')
// Pass debug globally
nikita({debug: true})
// Action has debugging activated
.system.execute({
  cmd: 'whoami'
})
```

## Getting started with logging

In case you wish to activate standard logging, here is a quick and easy way to get you started.

```js
node = {ip: '10.10.10.10', hostname: 'my_host'}
// Create a session
require('nikita')
// Activate CLI reporting
.log.cli({host: node.fqdn, pad:{host: 20}, header: 60})
// Activate log information written in Markdown
.log.md({basename: node.hostname, basedir: log.basedir, archive: false})
// Now start the real job
.ssh.open{header: 'SSH Open', host: node.ip}
```

It will print short messages to the standart output (`stdout`) and detailed information inside the "./log" folder which will be created in case it does not yet exist.

## Deep dive into logging

Nikita provide a flexible architecture to intercept information. Users can write logs to custom destinations in any format. To write your own logging actions, once you register it, you can choose among the following options:

- Listen to events   
  It is a flexible solution in which you listen to every events emitted by Nikita. However, it requires you to fully implemented what you wish to do with the data.
- Extending `nikita.log.stream`   
  It is an action which simplify the integration of new logging appender by expecting a [Node.js writable stream](https://nodejs.org/api/stream.html#stream_writable_streams) and a serializer object.
- Extending `nikita.log.fs`   
  Built upon the `nikita.log.stream` action, it provides basic fonctionnality to write information to the filesystem. You are only responsible for serializing the data. The `nikita.log.csv` and `nikita.log.md` actions are such examples.

### Listening to events

At the heart of this architecture is the [Nikita Events API](/usages/events/). A Nikita session extends the [native Node.js Events API](https://nodejs.org/api/events.html). All other mechanisms presented below rely on the events emitted inside the Nikita session. You may use the `on(event, handler)` function to catch event but extending the `nikita.log.stream` action is probably a bit easier, expecting a string writer and a serializer function.

### Extending `nikita.log.stream`

It is a low level action which is meant to be extended and not to be called directly. More specific actions could used the `nikita.log.stream` action by providing a [Node.js writable stream](https://nodejs.org/api/stream.html#stream_writable_streams) and a serializer object.

The serializer is an object which must be implemented by the user. Keys correspond to the event types and their associated value is a function which must be implemented to serialize the information.

### Extending `nikita.log.fs`

The `nikita.log.fs` action provide an easy and quick way to write your own logging actions. For example, both the `nikita.log.csv` and the `nikita.log.md` described below rely upon it. This way, you can leverage existing options:

* `archive` (boolean)   
  Save a copy of the previous logs inside a dedicated directory, default is
  "false".
* `basedir` (string)    
  Directory where to store logs relative to the process working directory.
  Default to the "log" directory. Note, if the "archive" option is activated
  log file will be stored accessible from "./log/latest".
* `filename` (string)   
  Name of the log file, contextually rendered with all options passed to
  the mustache templating engine. Default to "{{shortname}}.log", where 
  "shortname" is the ssh host or localhost.

For example, below is a lightly modify version of the `nikita.log.csv` action:

```js
module.exports = { ssh: false, handler: function({options}){
  this.log.fs({ serializer: {
    diff: function(log){
      return "${log.type},${log.level},${JSON.stringify log.message},\n"
    },
    end: function(){
      return "lifecycle,INFO,Finished with success,\n"
    },
    error: function(err){
      return "lifecycle,ERROR,${JSON.stringify err.message},\n"
    },
    header: function(log){
      return "${log.type},,,${log.header}\n"
    },
    text: function(log){
      return "${log.type},${log.level},${JSON.stringify log.message}\n"
    },
  }})
}}
```

## CLI reporting

The CLI reporting is build on top of the log events. It print pretty and colorful information to the standard output of your terminal. In case no tty is detected, no color formatting will be written by default unless the `color` options is "true" or made of an object.

The action will only report if the header option is found.

No argument is required by default:

```js
require('nikita')
.log.cli()
// No header, no report
.file.remove({
  target: '/tmp/a_file_exists'
})
// Header with status as true
.file.touch({
  header: 'A file exists, 1st try',
  target: '/tmp/a_file_exists'
})
// Header with status as false
.file.touch({
  header: 'A file exists, 2nd try',
  target: '/tmp/a_file_exists'
})
// Will output
// localhost   A file exists, 1st try   -  2ms\n
// localhost   A file exists, 2nd try   ✔  1ms\n
```

An action marked as disabled and which doesn't pass a condition is not reported to the CLI.

```js
require('nikita')
.log.cli({
  host: node.fqdn,
  pad: host: 20,
  header: 60
})
```

## CSV and Markdown logs

The `nikita.log.csv` and `nikita.log.md` actions both use the `nikita.log.fs` with a custom serializer. Thus, they support all the options from the `nikita.log.fs` action.
