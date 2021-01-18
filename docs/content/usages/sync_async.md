---
title: Sync and async
sort: 2
---

# Sync and async execution

The asynchronous nature of JavaScript coupled with how Nikita registers new actions can be a little tricky for newcomers. Handlers can be written in both synchronous and asynchronous based on the presence of a callback argument in the handler signature. Moreover, it is possible to write a synchronous handler which schedules asynchronous actions.

## Nikita session

A Nikita session is run asynchronously. Thus, any function declared after Nikita will be executed before Nikita has completed:

```js
require('nikita')
.next(function(){
  console.info('This is executed after');
});
console.info('This is executed before');
```

## The `call` action

When using the [`call` action](/usages/call/), [handler functions](/action/handler/) in Nikita are executed synchronously or asynchronously. Detection is based on the argument signature. Here's a simple example with the Node.js `fs.touch` function:

```js
require('nikita')
// Synchronous call
.call({file: '/tmp/sync_file'}, function({options}){
  fs.touchSync(options.file);
})
// Asynchronous call
.call file: '/tmp/async_file', function({options}, callback){
  fs.touch(options.file, callback;
)};
```

### Synchronous execution

Synchronous handlers take an optional "options" argument. The function signature is `handler([options])`.

Errors are simply thrown and caught by Nikita. There is no direct way to modify the status unless asynchronous handlers are called as children.

```js
require('nikita')
.call(function(){
  console.info('a first sync user function');
});
.call({type: 'sync'}, function({options}){
  console.info('a second ' + options.type + ' user function');
});
```

A powerful feature of Nikita is the ability to call asynchronous handlers inside synchronous handlers. This coding style is encouraged if it favor code readability but might look like black magic at first. Take the following code into consideration:

```js
require('nikita')
.call(function(){
  this.execute({
    cmd: "echo hostname: `hostname`"
  });
})
.next(function(){
  console.info('done');
});
```

The `execute` action is run asynchronously but it is declared inside a sync `call` action. This is made possible because calling an action in Nikita schedule the action for later execution. Think of it as a stack in which 3 actions will are scheduled: first an action named `call`, then a second action named `execute` and finally an action named `next`.

Status of the synchronous parent handler is bubbled up from asynchronous child handlers. The rule is as follow, if any child has a status set to "true", then the parent has a status set to "true".

```js
nikita
.call(function(){
  this.call(function({options}, callback){
    callback(null, false);
  });
  this.call(function({options}, callback){
    callback(null, true);
  });
}, function(err, {status}){
  if(err){ throw err; }
  assert(status === true);
});
```

### Asynchronous execution

Asynchronous handlers take 2 arguments. The function signature is `handler({options}, callback)`.

If any, errors are passed to the callback as its first argument. Otherwise, a value of "null" or "undefined" indicates a success. The second value is the status passed as boolean. Set it to "true" to indicate a change in state. Additional arguments will be transmitted to the callback function.

```js
require('nikita')
.call(function({options}, callback){
  setImmediate(function(){
    console.info('An async user function indicating a change in state');
    callback(null, true);
  });
})
.call(function({options}, callback){
  setImmediate(function(){
    console.info('An async user function passing an error');
    callback(Error('CatchMe'));
  });
});
```

## Action registration inside callbacks

Synchronous and asynchronous handlers can also be registered inside a callback. Back to the Node.js `fs.touch` function, an example is:

```js
require('nikita')
.file.wait({target: '/tmp/wait_for_file'}, function(err, {status}){
  // Entering the callback
  if(err){ return throw err };
  // Synchronous call
  this.call({file: '/tmp/sync_file'}, function({options}){
    fs.touchSync(options.file);
  })
  // Asynchronous call
  this.call file: '/tmp/async_file', function({options}, callback){
    fs.touch(options.file, callback;
  )};
})
```

## Status

Getting the right status can also be a bit confusing. It is quite common to condition the execution of an action to a change in state. In such case, a call to `this.status()` is associated with a condition such as `if`.

However, setting the value of the `if` property directly as the value returned `this.status()` will give you the state of the current scope, probably not the one you expect.

```js
require('nikita')
.call({header: 'Install MyComponent'}, function(){
  this.tools.git({
    source: "http://localhost/my_component.git",
    target: "/tmp/my_component"
  })
  this.execute({
    if: this.status(),
    cmd: '/tmp/my_component/bin/restart.sh'
  })
})
```

Here, the call to `this.status()` does not return the state of the git action declared just before. Instead, it reflect the status of the parent action, which is always "false". Instead, this example should be rewritten with `this.status()` wrapped inside a function:

```js
require('nikita')
.call({header: 'Install MyComponent'}, function(){
  this.tools.git({
    source: "http://localhost/my_component.git",
    target: "/tmp/my_component"
  })
  this.execute({
    if: function(){ this.status() },
    cmd: '/tmp/my_component/bin/restart.sh'
  })
})
```
