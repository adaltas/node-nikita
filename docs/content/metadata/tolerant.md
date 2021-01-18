---
title: Metadata "tolerant"
---

# Metadata "tolerant" (boolean, optional, false)

The "tolerant" metadata guaranty the execution of any action wether there was an error or not in a previous actions.

## Usage

The sleep value is a a boolean activating the metadata if `true`. By default, the metadata is set to `false`

```js
require('nikita')
.call(function(){
  throw Error('Oh no!')
})
.call({
  tolerant: true
}, function(){
  console.info('I am executed')
})
```
