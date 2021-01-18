---
sort: 3
---

# Status

The status is an information indicating whether an action had any impact or not. Its meaning may differ from one action to another. Here are a few examples:

- touching a file   
  The status is "true" if the file was created or any metadata associated with the file has changed, such as the modification time or a change of ownership.
- modification of a configuration file (json, yaml, ini...)   
  The status is true if a property or any metadata associated with the file has changed. A change of format, like prettifying the source code, will not affect the status while the addition of a new property and the modification on the value of an existing property will set the status to "true".
- checking if a port is open
  The status is set to "true" if a server is listening on that port and "false" otherwise. This is arguably an alternative usage. In such case, it is often used conjointly with the "shy" metadata to ensure that parent actions don't get their status modified.

Status is a central concept in Nikita implemented inside every action. Early on, it was decided that actions will be idempotent and indicate whether a change occurred or not. The latter is what we call the status. It is formalised as a simple boolean passed to the callback as the `status` property. It is also available to subsequent action through the `getStatus` function.

When a handler is made of multiple child actions, the status will be `true` if at least one of the child action has a status of `true`.

## Sync versus Async handlers

Asynchronous handlers receive a callback. Once completed, the callback may be called with an error argument followed by an object containing the status property as its second argument or a Boolean value for its shorter version.

```javascript
require('nikita')
// Parent action
.call(function({config}, callback){
  // Do something
  setImmediate(function(){
    // Set the status to "true", default is "false"
    callback(null, true)
  });
}, function(err, {status}){
  // Status is now "true" in the callback
  assert(status === true)
})
.call(function(){
  // Status of the previous action is "true"
  assert(getStatus(-1) === true)
})
```

Synchronuous handlers don't modify the status directly. Instead, the status is derived from its child handlers.

```javascript
require('nikita')
// Parent action
.call(function(){
  // Do something
}, function(err, {status}){
  // By default, status is "false"
})
// Parent action
.call(function(){
  // Child action
  this.call(function({config}, callback){
    // Set the status to "true"
    callback(null === true)
  })
}, function(err, {status}){
  // Status is now "true"
  assert(status === true)
})
```

## Using it with `next`

The `next` function is called once a list of actions has terminated or if any error occurred before. When called, it expect a function with the error and status provided as arguments. Once `next` is called, the status is reset and a new run of actions may be scheduled.

```js
require('nikita')
// All actions are false
.call(function({config}, callback){
  callback(null, false)
})
.call(function({config}, callback){
  callback(null, false)
})
// Then status is false
.next(function(err, {status}){
  assert(status, false)
})
// One actions is true
.call(function({config}, callback){
  callback(null, false)
})
.call(function({config}, callback){
  callback(null, true)
})
.call(function({config}, callback){
  callback(null, false)
})
// Then status is true
.next(function(err, {status}){
  assert(status, true)
})
```
