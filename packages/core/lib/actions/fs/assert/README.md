
# `nikita.fs.assert`

Assert a file exists or a provided text match the content of a text file.

## Output

* `err` (Error)   
  Error if assertion failed.   

## Example

Validate the content of a file:

```js
nikita.fs.assert({
  target: '/tmp/a_file', 
  content: 'nikita is around'
})
```

Ensure a file does not exists:

```js
nikita.fs.assert({
  target: '/tmp/a_file',
  not: true
})
```
