
# `nikita.assert`

Assert that a handler function return or resolve to `true` or an array where all its elements equals to `true`.

When calling children, ensure they return `true` and that the value is not altered with the `raw_output` metadata.

When the `not` option is active and if an array is returned, all the items must equals `false` for the assertion to succeed.

## Casting rules

Casting is activated by default and is disabled when the `strict` configuration is active.

- Strings and buffers are `true` unless empty
- Numbers above `0` are `true`
- Values of `null` and `undefined` are `false`
- Object literals are `true` if they contain keys
- Function are invalid and throw a `NIKITA_ASSERT_INVALID_OUTPUT` error

## Status

The `$status` property returned a value `false`. Thus, the parent's action status is not altered.

## Examples

Assert succeed when the handler return `true`:

```js
nikita.assert( () => {
  return true
})
```

Assert succeed when the handler return a promise which resolves with `true`:

```js
nikita.assert( () => {
  return new Promise( (resolve) => {
    resolve(true)
  })
})
```
