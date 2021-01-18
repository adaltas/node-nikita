---
title: Config
sort: 1
---

# Metadata "config"

Config are used to contextualise the handler function.

## Usage

They are usually provided as an object when calling an action. For example, the `system.execute` action can receive on object with a "cmd" property:

```js
nikita
// Object with "cmd" config
.system.execute({cmd: 'whoami'})
```

## Short declaration

The `system.execute` action can also receive the command as a string. This declaration achieve the same result as the previous example:

```js
nikita
// Command as a string
.system.execute('whoami');
```

The string config in the previous example is here for conveniency. Internally, the execute handler receives config as an object and search for the "argument" config. Here's an example:

```js
nikita
.register('execute', function({config}, callback){
  config.cmd = config.argument if typeof config.argument is 'string'
  // More code goes here
});
.execute('whoami', function(err, {stdout}){
  console.info('I am ' + stdout.trim());
})
```

## Merging

When multiple configs are passed, they will be merged with the last keys taking precedence over previously defined keys:

```js
nikita
.call({key: 'old value'}, {key: 'new value'}, function({config}){
  assert(config.key, 'mew value')
})
```

Values set as `undefined` are passed but they will not overwrite previously defined config:

```js
nikita
.call({key: 'value'}, {key: undefined}, function({config}){
  assert(config.key, 'value')
})
```

## Global definition

Config passed to the Nikita session on instantiation are available globally to every handlers.

```js
nikita({
  my_config: 'my value'
})
.call(function({config}){
  console.info(`Value of "my_config" is ${config.my_config}`);
});
```
