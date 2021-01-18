---
title: Metadata "tolerant"
redirects:
- /options/tolerant/
---

# Metadata "tolerant" (boolean, optional, false)

## Description

The "tolerant" option guaranty the execution of any action wether there was an error or not in a previous actions.

## Usage

The sleep value is a a boolean activating the option if `true`. By default, the option is set to `false`

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
