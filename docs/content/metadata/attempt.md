---
title: Metadata "attempt"
---

# Metadata "attempt" (number, readonly, 0)

The "attempt" metadata is an indicator of the number of times an action has been rescheduled for execution when an error occurred.

It is only readable from inside an handler function. An attempt to pass this metadata when calling an action will have no incidence. It is meant to be used conjointly with the ["retry" metadata](/metadata/retry/).

## Usage

The associated value is incremented after each retry starting with the value "0". The following example will failed on the first attempt before finally succeed on its second attempt.

```js
require('nikita')
.call({
  retry: 2
}, function({config}, callback){
  if(config.attempt === 0){
    throw Error('Oups')
  }
  callback(null, true)
}, function(err, {status}){
  // The first attempt failed with an error
  assert(err, undefined)
  // but the second attempt succeed
  assert(status, true)
})
```
