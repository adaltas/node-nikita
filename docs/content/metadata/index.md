---
title: Metadata
sort: 4
---

# Metadata

Metadata is a plain JavaScript object used to contextualise the execution of an action.

## Available properties

* [`attempt`](/metadata/attempt/) (number, readonly, 0)
  Indicates the number of times an action has been rescheduled for execution when an error occurred.
* [`debug`](/metadata/debug/) (boolean, optional, false)   
  Print detailed logs to the standard error output (`stderr`).
* [`header`](/metadata/header/) (string, optional)   
  Title of an actions or of a group of actions.
* [`once`](/metadata/once/) (boolean|array|string, optional, false)   
  Ensure that the same actions are only executed once.
* [`relax`](/metadata/relax/) (boolean, optional, false)   
  Makes an action tolerant to internal errors.
* [`retry`](/metadata/retry/) (number|boolean, optional, 1)   
  Control over how many time an action is re-scheduled on error before it is finally treated as a failure.
* [`shy`](/metadata/shy/) (boolean, optional, false)   
  Disables the modification of the session status.
* [`sleep`](/metadata/sleep/) (number, optional, 3000)   
  Time lapse when a failed action is rescheduled.
* [`tolerant`](/metadata/tolerant/) (boolean, optional, false)   
  Guaranty the execution of any action wether there was an error or not in a previous actions.
* [`sudo`](/metadata/sudo/) (boolean, optional, false)   
  Escalates the right of the current user with `root` privileges.

## Usage

Using metadata is as easy as passing one or multiple metadata when calling an action:

```js
require('nikita')
.call({metadata: {header: 'my action'}}, function({metadata}){
  assert(metadata.header, 'my action')
})
```

<!-- ## Available actions

Each actions in Nikita expect specific options. You must consult the documentation of each individual actions to know in detail which options are available.

Some actions are globally available to every actions. They are defined and managed by Nikita itself. You can consult the documentation of each option to obtain detailed information about its usage and behaviour. -->
