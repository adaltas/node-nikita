---
title: Options
sort: 1
---

# Metadata "options"

Options are used to contextualise the handler function.

## Usage

They are usually provided as an object when calling an action. For example, the `system.execute` action can receive on object with a "cmd" property:

```js
nikita
// Object with "cmd" option
.system.execute({cmd: 'whoami'})
```

## Short declaration

The `system.execute` action can also receive the command as a string. This declaration achieve the same result as the previous example:

```js
nikita
// Command as a string
.system.execute('whoami');
```

The string options in the previous example is here for conveniency. Internally, the execute handler receives options as an object and search for the "argument" option. Here's an example:

```js
nikita
.register('execute', function({options}, callback){
  options.cmd = options.argument if typeof options.argument is 'string'
  // More code goes here
});
.execute('whoami', function(err, {stdout}){
  console.info('I am ' + stdout.trim());
})
```

## Safe declaration

When passing option, be careful to not collide with a metadata property. To be safe, pass every options inside an `options` property.

```js
nikita
.call({retry: 1}, function({metadata, options}){
  assert(metadata.retry, 1)
  assert(options.retry, undefined)
})
.call({options: {retry: 1}}, function({metadata, options}){
  assert(metadata.retry, 3)
  assert(options.retry, 1)
})
```

## Merging

When multiple options are passed, they will be merged with the last keys taking precedence over previously defined keys:

```js
nikita
.call({key: 'old value'}, {key: 'new value'}, function({options}){
  assert(options.key, 'mew value')
})
```

Values set as `undefined` are passed but they will not overwrite previously defined options:

```js
nikita
.call({key: 'value'}, {key: undefined}, function({options}){
  assert(options.key, 'value')
})
```

## Global definition

Options passed to the Nikita session on instantiation are available globally to every handlers.

```js
nikita({
  my_option: 'my value'
})
.call(function({options}){
  console.info(`Value of "my_option" is ${options.my_option}`);
});
```
