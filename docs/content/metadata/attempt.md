---
title: Metadata "attempt"
redirects:
- /options/attempt/
---

# Metadata "attempt" (number, readonly, 0)

## Introduction

The "attempt" property is an indicator of the number of times an action has been rescheduled for execution when an error occurred.

It is only readable from inside an handler function. An attempt to pass this option when calling an action will have no incidence. It is meant to be used conjointly with the ["retry" option](/metadata/retry/).

## Usage

The associated value is incremented after each retry starting with the value "0". The following example will failed on the first attempt before finally succeed on its second attempt.

```js
require('nikita')
.call({
  retry: 2
}, function({options}, callback){
  if(options.attempt === 0){
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
