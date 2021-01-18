---
title: Metadata "shy"
---

# Metadata "shy" (boolean, optional, false)

The "shy" metadata disables the modification of the session status.

Sometimes, some actions are not relevant to indicate of change of status. There are multiple reasons for this. For example, the nature of the action itself is meaningless, like checking prerequisites, or the change of status is assumed by another sibling action.

## Usage

The shy metadata is a boolean. The value is `false` by default. Set the value to `true` if you wish to activate the metadata. The following example check that Redis is installed before starting a service.

```js
require('nikita')
.call({shy: true}, function(){
  this.fs.exists({target: "/path/to/redis"}, function(err, exists){
    if(err) throw err
  })
})
.system.execute({
  code_skipped: 3,
  cmd: `
  /path/to/redis/redis-cli ping && exit 3
  nohup /path/to/redis/redis-server /path/to/redis/redis.conf &
  `
})
.next(function(err, {status}){
  // Status is only affected by the `system.execute` action
  console.info(err ? err.message : 'Redis started: ' + status)
})
```

## Callback

The "callback" function will receive the status of the action no matter if the "shy" metadata is activated or not.

```js
require('nikita')
// Shy is desactivated, default behavior
.call({shy: false}, function(_, callback){
  callback(null, true)
}, function(err, {status}){
  assert(status, true)
})
// Shy is activated
.call({shy: true}, function(_, callback){
  callback(null, true)
}, function(err, {status}){
  assert(status, true)
})
```

## Status function

The [status function](/usages/status/) is not affected by the "shy" metadata. We could now rewrite the previous example above to start Redis. Instead of relying on a specific exit code to infor our `nikita.system.execute` action that Redis is started, we could split the code in 2 actions. The first one test if redis is started and doesn't activate the status if it is. The second one start Redis only if the status of the previous action is active.

```js
require('nikita')
.system.execute({
  shy: true,
  cmd: '/path/to/redis/redis-cli ping'
})
.system.execute({
  unless: function(){ this.status(-1) },
  cmd: 'nohup /path/to/redis/redis-server /path/to/redis/redis.conf &'
})
.next(function(err, {status}){
  console.info(err ? err.message : 'Redis started: ' + status)
})
```
