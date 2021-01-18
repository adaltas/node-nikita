---
title: Metadata "sleep"
redirects:
- /options/sleep/
---

# Metadata "sleep" (number, optional, 3000)

## Description

The "sleep" option indicates the time lapse when a failed action is rescheduled. It only has effect if the "attempt" option is set to a value greater than 1 and when the action failed and is rescheduled.

## Usage

The sleep value is an integer and is interpreted in millisecond. The default value is "3000". Here is an example raising the sleep period to 5 seconds.

```js
require('nikita')
.system.execute({
  cmd: '[ `whoami` == "root"]',
  retry: 3,
  sleep: 5000
})
```

Any value not superior or equal to zero will generate an error.

## Default value

While you can set this option on selected actions, it is safe to declare it at the session level. In such case, it will act as the default value and can still be overwritten on a per action basis.

```js
require(nikita)({
  sleep: 5000
})
// Wait 5 seconds between retries
.call({
  retry: 3,
}, function({options}){
  if( options.attempt < 3 ) throw Error 'Action Failure'
})
// Wait 1 second between retries
.call({
  retry: 3,
  sleep: 1000
}, function({options}){
  if( options.attempt < 3 ) throw Error 'Action Failure'
})
```
