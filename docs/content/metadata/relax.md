---
title: Metadata "relax"
redirects:
- /options/relax/
---

# Metadata "relax" (boolean, optional, false)

The "relax" option makes an action tolerant to internal errors.

Sometimes, you wish to handle errors not in the action itself but inside the callback function or inside another sibling action executed before or after. This option is also often used conjointly with the status. For example, you may to execute a shell process and interpret non-zero codes as non fatal. 

## Usage

The value is a boolean with value `false` as default. Simply set the action to a value `true` to enable the relax behavior.

In the example below, we start the MariaDB service with the `systemctl` command. If the service is not installed or already started, the result is a non-zero code, resulting with an error unless the "relax" option is activated, but we don't want to deal with it:

```js
require('nikita')
.system.execute({
  relax: true
  cmd: `
  systemctl start mariadb
  `
})
```

## Callback

The "relax" option doesn't alter the error argument passed in the "callback" function. Any error sent by the "handler" function is available as the first argument in the "callback" function. Additionally, the "relax" option has no influence if an error is thrown inside the callback. Any error thrown by the "callback" function will be interpreted as such by the Nikita session.

In the example below, we leverage this behavior to throw an error depending and the "status" argument:

```js
require('nikita')
.call({
  relax: true
},function(_, callback){
  callback(null, Math.round(Math.random())
}, function(err, {status}){
  if(err) throw err
  if(!status) throw Error('You are out of luck')
})
.next(function(err){
  if(err) assert(err.message, 'You are out of luck')  
})
```
