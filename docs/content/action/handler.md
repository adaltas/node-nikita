---
title: Handler
sort: 2
---

# Metadata "handler" (function, required)

The "handler" property define the function that an action implements to get things done. It is fundamental to each action.

The property is required but most of the time, you don't have to write an handler function on your own. Instead, you will use an existing action which was previously [registered](/usages/registry/).

However, you should not be afraid to write your own handler, it is as easy as writing a plain vanilla JavaScript function and using the Nikita `call` action to schedule its execution. Functions can run [synchronously or asynchronously](/usages/sync_async/).

## Synchronous handlers

Synchronous handlers expect one arguments, the config passed to the action:

```js
require('nikita')
.call({
  key: 'value',
  handler: function({config}){
    // do something
    assert(config.key, 'value')
  }
})
```

## Asynchronous handlers

Asynchronous handlers expect two arguments, the config and a callback function to be called when the action has terminated:

```js
require('nikita')
.call({
  key: 'value',
  handler: function({config}, callback){
    setImmediate(function(){
      // do something
      assert(config.key, 'value')
    })
  }
})
```

## Style

You will probably never see an handler function being defined by the "handler" config key. Instead, we define it with an alternative syntax by passing the handler function as an independent argument. The example above is preferably rewritten as:

```js
require('nikita')
.call({
  key: 'value'
}, function({config}, callback){
  setImmediate(function(){
    // do something
    assert(config.key, 'value')
  })
})
```

The rule to interpret function arguments is as follow: the first encountered function is the handler unless the action is registered with an existing handler function; the second encountered function is the callback.

## Asynchronous handlers inside synchronous handlers

Synchronous functions may call child action which are executed asynchronously. The next sibling action will not be schedule for execution before all the child actions have been executed.

```js
require('nikita')
.call(function({config}){
  console.info('1')
  this.call(function({config}, callback){
    setImmediate(function(){
      console.info('2')
    })
  })
})
.call(function({config}){
  console.info('3')
})
```
