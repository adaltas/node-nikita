---
sort: 4
---

# Metadata

Metadata is a plain JavaScript object with properties used to contextualise or modify the execution of an action. The metadata properties are common to all Nikita actions.

## Usage

Using metadata is as easy as passing one or multiple properties when calling an action:

```js
nikita
// Call an action with the `header` metadata
.execute({
  // highlight-range{1-3}
  metadata: {
    header: 'Check user'
  },
  command: 'whoami'
})
```

## Available metadata properties

* [`attempt`](/current/metadata/attempt/) (number, readonly, 0)
  Indicates the number of times an action has been rescheduled for execution when an error occurred.
* [`debug`](/current/metadata/debug/) (boolean, false)   
  Print detailed logs to the standard error output (`stderr`).
* [`header`](/current/metadata/header/) (string)   
  Title of an actions or of a group of actions.
* [`once`](/metadata/once/) (boolean|array|string, false)   
  Ensure that the same actions are only executed once.
* [`relax`](/current/metadata/relax/) (boolean, false)   
  Makes an action tolerant to internal errors.
* [`retry`](/current/metadata/retry/) (number|boolean, 1)   
  Control over how many time an action is re-scheduled on error before it is finally treated as a failure.
* [`shy`](/current/metadata/shy/) (boolean, false)   
  Disables the modification of the session status.
* [`sleep`](/current/metadata/sleep/) (number, 3000)   
  Time lapse when a failed action is rescheduled.
* [`sudo`](/metadata/sudo/) (boolean, false)   
  Escalates the right of the current user with `root` privileges.
