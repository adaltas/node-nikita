---
title: Cascade
sort: 5
redirects:
- /options/cascade/
---

# Metadata "cascade" (object|array, optional)

Options may be propagated to every child actions. This is not the default behavior, options are not passed to child actions unless they are declared by the "cascade" option.

It sometimes convenient to pass specific options to an action. For example, an action which write files in a specific format may itself rely on the `nikita.file` action to handle changes of ownerships and permissions. Another example is the "ssh" option which activate or desactivate ssh for an action and all its children.

## Usage

To do so, cascaded options must be declared inside the "cascade" option which is an object where keys represent the option to propagate and values are a boolean indicated whether an option is propagated or not:

```js
require('nikita')
.call({
  a_cascaded_option: 'a cascaded value',
  a_regular_option: 'another value',
  cascade: {
    a_cascaded_option: true
  }
}, function(){
  this.call(function({options}){
    assert(options.a_cascaded_option, 'a cascaded value')
    assert(options.a_regular_option, undefined)
  })
})
```

Note, the "cascade" option may also be declared as an array. In such case, all options defined inside the array will be cascaded. The previous example is identical to:

```js
require('nikita')
.call({
  a_cascaded_option: 'a cascaded value',
  a_regular_option: 'another value',
  cascade: ['a_cascaded_option']
}, function(){
  this.call(function({options}){
    assert(options.a_cascaded_option, 'a cascaded value')
    assert(options.a_regular_option, undefined)
  })
})
```

## Hiding an option

When the value is false, the option is never transmitted. It will not be made available to the current action nor to its children:

```js
require('nikita')
.call({
  invisible_option: 'a value',
  cascade: {
    invisible_option: false
  }
}, function({options}){
  assert(options.invisible_option, undefined)
})
```

The following actions are not passed: `after`, `before`, `disabled`, `domain`, `handler`, `header`, `once`, `relax`, `shy`, `sleep`.

Use a value of `null` or `undefined` to achieve the default behavior where options are passed to the current action but not to its children.

## Global definition

To avoid declaring a option as cascaded over and over, it is also possible to define it globally, across all Nikita session:

```js
require('nikita')
.cascade.my_cascaded_option = true
```

The following options are globally cascaded: `cwd`, `ssh`, `log`, `stdout`, `stderr`, `debug`, `sudo`.

Be carefully when using this functionality as it will affect every created and future Nikita sessions.

## Session definition

When an option must be globally cascaded and to avoid polluting the global context, it is recommended to declare it when initializing the session.

```js
require('nikita')({
  cascade: {
    my_cascaded_option: true
  }
})
.call({my_cascaded_option: 'a value'}, function(){
  // Option my_cascaded_option will be passed to child actions
  this.call(function({options}){
    assert(my_cascaded_option, 'a value')
  })
})
```
