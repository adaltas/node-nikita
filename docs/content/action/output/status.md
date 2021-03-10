---
sort: 3
---

# Status

The status is information indicating whether Nikita's action had any impact or not. It is a central Nikita concept implemented inside every action and formalized as a boolean value returned to the [action output](/current/action/output) as the `status` property.

The status meaning may differ from one action to another, here are a few examples:

- *Touching a file*   
  The status is `true` if the file was created or any metadata associated with the file has changed, such as the timestamp modification or a change of ownership.
- *Modification of a configuration file (JSON, YAML, INI...)*   
  The status is `true` if a property or any metadata associated with the file has changed. A change of format, like prettifying the source code, will not affect the status, while the addition of a new property or the modification on the value of existing property will set the status to `true`.
- *Checking if a port is open*   
  The status is set to `true` if a server is listening on that port and `false` otherwise. This is arguably an alternative usage. In such a case, it is often used conjointly with the [`shy` metadata](/current/metadata/shy) to ensure that parent actions don't get their status modified.

## Idempotency

Nikita actions are idempotent, and the status indicates whether a change occurred after calling the action or not. For example, when calling the `nikita.file.touch` action, the status is `true` if the file was created. However, the second call returns the status of `false`:

```js
nikita
.call(async function(){
  const path = '/tmp/nikita/a_file'
  // Remove the file to make sure it is not exist
  this.fs.remove(path)
  // Touch 1st time
  var {status} = await this.file.touch(path)
  console.info(status)  // true
  // Touch 2nd time
  var {status} = await this.file.touch(path)
  console.info(status)  // false
})
```

## Changing the status value

By default, Nikita's actions return the status value of `false`. It can be changed by the [action handler](/current/action/handler) or the child actions. 

The handler modifies the status when it returns a boolean value or an object with the `status` property:

```js
nikita
.call(async function(){
  // Default value
  var {status} = await this.call(() => {return})
  console.info(status)  // false
  // Return boolean
  var {status} = await this.call(() => true)
  console.info(status)  // true
  // Return object
  var {status} = await this.call(() => {return {status: true}})
  console.info(status)  // true
})
```

When the [action handler](/current/action/handler) is made of multiple child actions, the status is `true` if at least one of the child actions has a status of `true`:

```js
(async () => {
  var {status} = await nikita
  // Parent action
  .call(async function(){
    // Child action, returns `false`
    this.call(() => false)
    // Child action, returns `true`
    this.call(() => true)
  })
  console.info(status)  // true
})()
```
