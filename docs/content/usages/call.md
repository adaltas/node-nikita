---
title: Call
sort: 2
state: review
---

# Call and user defined handlers

## Introduction

Nikita gives you the choice between calling your own function, which we call handlers, or calling an [registered function][registered] by its name.

## Calling a function

In its simplest form, user defined handler is just a function passed to "call". Here's an illustration:

```js
nikita
.call(function({options}, callback){
  fs.touch(options.file, callback);
});
```

This is internally converted to:

```js
nikita
.call({
  handler: function({options}, callback){
    fs.touch(options.file, callback);
  }
});
```

Use the expanded object syntax to pass additional information. For example, we could add the retry option:

```js
nikita
.call({
  retry: 2,
  handler: function({options}, callback){
    fs.touch(options.file, callback);
  }
});
```

Note, the above code could be arguably simplified using 2 arguments:

```js
nikita
.call({
  retry: 2,
}, function({options}, callback){
  fs.touch(options.file, callback);
});
```

## Calling a module

If no handler is yet defined, a string is interpreted as an external module exporting a handler function or object. The 3 calls below are all equivalents:

```js
nikita
// String with an additionnal option object
.call( 'path/to/module', {
  retry: 2,
})
// Expanded object syntax
.call({
  handler: 'path/to/module'
  retry: 2
});
```

Internally, module are required with the call `require.main.require`.

[registered]: ./registered_handlers
