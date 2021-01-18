---
title: Action Registration
description: Registration API - register and access actions by names
keywords: registry, API, actions
sort: 3
---

# Action Registration

## Introduction

The registration API allows actions to be registered and access by names. To write an action commonly involves writting a function and schedule it for execution by using the `call` action:

```js
require('nikita')
.call(function(){
  @service('redis');
  @file.ini({
    target: '/etc/redis.conf',
    properties: { port: 6379 },
    delimiter: ' ',
    merge: true
  });
});
```

This is appropriate for specific usages. However, it is sometime better to encapsulate the code and make it available to everyone. In such cases, you can register a Nikita action by it name. Action can be registered to globally to every Nikita instances and locally to a single instance.

## Global registration

When registered globally, an action will be made available to every Nikita instance.

For example, the above example could be registered and accessed by the name `nikita.redis.install()` :

```js
require('nikita')
.register(['redis', 'install'], function({options}){
  if( !options.conf_file ){
    options.conf_file = '/etc/redis.conf'
  }
  if( !options.properties ){
    options.properties = {}
  }
  if( !options.properties.port ){
    options.properties.port = 6379
  }
  @service('redis');
  @file.ini({
    target: '/etc/redis.conf',
    properties: options.properties
    delimiter: ' ',
    merge: true
  });
});
```

Now, anyone could require the above module, let's call it "redis/install.js" and use it:

```js
require('./redis/install');
require('nikita')
.redis.install({port: 6379})
.then(function(err, {status}){
  console.info(err || 'Redis Installation '+(status?'+':'-'));
})
```

## Local registration

When registered locally, the action is only available to from one Nikita instance, without modifying the global scope.

For example, our Redis example could be re-written :

```js
moodule.exorts = function(nikita){
  nikita
  .register(['redis', 'install'], function({options}){
     if( !options.conf_file ){
       options.conf_file = '/etc/redis.conf'
     }
     if( !options.properties ){
       options.properties = {}
     }
     if( !options.properties.port ){
       options.properties.port = 6379
     }
     @service('redis');
     @file.ini({
       target: '/etc/redis.conf',
       properties: options.properties
       delimiter: ' ',
       merge: true
     });
   });
}
```

Now, a new Nikita instance can be created from which a new action will be registered :

```js
nikita = require('nikita');
// Initialize
n = nikita();
require('./redis/install')(n);
// Execute
n
.redis.install({port: 6379})
.then(function(err, {status}){
  console.info(err || 'Redis Installation '+(status?'+':'-'));
})
```

## API

The following methods are available:

* `nikita.get(name)`   
  Retrieve an action by name.
* `nikita.register(name, action)`   
  `nikita.register(actions)`   
  Register new actions.
* `nikita.deprecate(old_function, [new_function], action)`   
  Deprecate an old or renamed action. Internally, it leverages 
  [Node.js `util.deprecate`][deprecate].
* `nikita.registered(name)`   
  Test if a function is registered or not.
* `nikita.unregister(name)`
  Remove an action from registry.
* `nikital.registry()`   
  Return all the action registry.

All the above function are also available both globally and locally. For example `require('nikita').register('action', '/path/to/action')` register an action globally while the same action will be attache locally to a single Nikita instance instance with `require('nikita')(options).register('action', '/path/to/action')`.

## Registration

It is possible to register one action or multiple actions at once. Also, as illustrated from the above example, the name referencing an action can be composed of one or multiple properties.

With an action path:

```javascript
nikita.register('first_action', 'path/to/action')
nikita.first_action(options);
```

With a namespace and an action path:

```javascript
nikita.register(['second', 'action'], 'path/to/action')
nikita.second.action(options);
```

With an action object:

```javascript
nikita.register('third_action', {
  relax: true,
  handler: function({options}){ console.info(options.relax) }
})
nikita.third_action(options);
```

With a namespace and an action object:

```javascript
nikita.register(['fourth', 'action'], {
  relax: true,
  handler: function({options}){ console.info(options.relax) }
})
nikita.fourth.action(options);
```

Multiple actions:

```javascript
nikita.register({
  'fifth_action': 'path/to/action'
  'sixth': {
    '': 'path/to/sixth',
    'action': : 'path/to/sixth/actkon'
  }
})
nikita
.fifth_action(options);
.sixth(options);
.sixth.action(options);
```
