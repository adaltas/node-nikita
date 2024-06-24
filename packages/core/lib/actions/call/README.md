
# `nikita.call`

A generic action to call user defined action. It expects the action as a
parameter. It can be the object representing the action or only the handler
function. Alternatively, a string is interpreted as the path to module which
is then required and executed.

## Passing an action

```js
const {key} = await nikita.call({
  config: {
    key: 'value'
  },
  handler: ({config}) => config.key
})
assert(key === 'value')
```

## Passing a function

```js
const key = await nikita.call( () => 'value' )
assert(key === 'value')
```

You can also provide the fuction among other arguments:

```js
const key = await nikita.call( {
  key: 'value'
}, ({config}) => {
  return config.key
})
assert(key === 'value')
```

## Using a module path

```js
const value = await nikita(function(){
  await this.fs.writeFile({
    content: 'export default ({config}) => "my secret"',
    target: '/tmp/my_module'
  })
  return this.call( '/tmp/my_module' )
})
assert(value === 'value')
```
