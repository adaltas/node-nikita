---
sort: 8
---

# Error handling

Nikita implements error management by following familiar [Node.js](https://nodejs.org) conventions. The handling of errors different slightly between synchronous and asynchronous functions.

## Emitting errors

Synchronous handlers may throw an error:

```js
require('nikita')
// Synchronous function
.call(function({config}){
  // Throw the error
  throw Error 'Catch me'
})
// Catch the error
.next(function(err){
  console.info(err.message)  
})
```

Asynchronous handlers must pass the error as the first argument of the callback.

```js
require('nikita')
// Synchronous function
.call(function({config}, callback){
  setImmediate(function(){
    // Throw the error
    callback(Error 'Catch me')
  })
})
// Catch the error
.next(function(err){
  console.info(err.message)  
})
```

## Catching errors

In case an error encountered, the sequence of actions is interrupted and the Nikita session will exit with a failure. The error can be catch in the action callback, with the `nikita.next` function or with the 'error' event.

The behavior can be altered to treat error as non destructive. Using the `relax` metadata, the error will be available in the callback function but the sequence of actions will not be interrupted and the error will not be propagated to any other actions.

```js
require('should')
require('nikita')
// Pass the relax metadata
.call({relax: true}, function({config}){
  // Throw the error
  throw Error 'Catch me'
}, function(err){
  // Error is available in the action callback
  err.message.should.eql 'Catch me'
})
// Keep working
.call(function({config}, callback){
  setImmediate(function(){
    callback(null, true)
  })
})
// Finalize the session
.next(function(err){
  // Error is not propagated
  (err === undefined).should.be.true()
  // Status was changed by the second action
  status.should.be.true()
})
```
