
# `nikita.file.json`

Write content in the JSON format.

## Example

Merge the destination file with user provided content.

```js
const {$status} = await nikita.file.json({
  target: "/path/to/target.json",
  content: { preferences: { colors: 'blue' } },
  transform: function(data){
    if(data.indexOf('red') < 0){ data.push('red'); }
    return data;
  },
  merge: true,
  pretty: true
})
console.info(`File was merged: ${$status}`)
```
