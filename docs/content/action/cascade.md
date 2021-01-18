---
title: Cascade
sort: 5
---

# Metadata "cascade" (object|array, optional)

Config may be propagated to every child actions. This is not the default behavior, config is not passed to child actions unless it is declared by the "cascade" config.

It sometimes convenient to pass specific config to an action. For example, an action which write files in a specific format may itself rely on the `nikita.file` action to handle changes of ownerships and permissions. Another example is the "ssh" config which activate or desactivate ssh for an action and all its children.

## Usage

To do so, cascaded config must be declared inside the "cascade" config which is an object where keys represent the config to propagate and values are a boolean indicated whether an config is propagated or not:

```js
require('nikita')
.call({
  a_cascaded_config: 'a cascaded value',
  a_regular_config: 'another value',
  cascade: {
    a_cascaded_config: true
  }
}, function(){
  this.call(function({config}){
    assert(config.a_cascaded_config, 'a cascaded value')
    assert(config.a_regular_config, undefined)
  })
})
```

Note, the "cascade" config may also be declared as an array. In such case, all config defined inside the array will be cascaded. The previous example is identical to:

```js
require('nikita')
.call({
  a_cascaded_config: 'a cascaded value',
  a_regular_config: 'another value',
  cascade: ['a_cascaded_config']
}, function(){
  this.call(function({config}){
    assert(config.a_cascaded_config, 'a cascaded value')
    assert(config.a_regular_config, undefined)
  })
})
```

## Hiding a config

When the value is `false`, the config is never transmitted. It will not be made available to the current action nor to its children:

```js
require('nikita')
.call({
  invisible_config: 'a value',
  cascade: {
    invisible_config: false
  }
}, function({config}){
  assert(config.invisible_config, undefined)
})
```

The following actions are not passed: `after`, `before`, `disabled`, `domain`, `handler`, `header`, `once`, `relax`, `shy`, `sleep`.

Use a value of `null` or `undefined` to achieve the default behavior where config is passed to the current action but not to its children.

## Global definition

To avoid declaring a config as cascaded over and over, it is also possible to define it globally, across all Nikita session:

```js
require('nikita')
.cascade.my_cascaded_config = true
```

The following config is globally cascaded: `cwd`, `ssh`, `log`, `stdout`, `stderr`, `debug`, `sudo`.

Be carefully when using this functionality as it will affect every created and future Nikita sessions.

## Session definition

When a config must be globally cascaded and to avoid polluting the global context, it is recommended to declare it when initializing the session.

```js
require('nikita')({
  cascade: {
    my_cascaded_config: true
  }
})
.call({my_cascaded_config: 'a value'}, function(){
  // Config my_cascaded_config will be passed to child actions
  this.call(function({config}){
    assert(my_cascaded_config, 'a value')
  })
})
```
