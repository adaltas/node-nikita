
# `nikita.tools.rubygems.fetch`

Fetch a Ruby gem.

## Output

* `$status`   
  Indicate if a gem was fetch.
* `filename`   
  Name of the gem file.
* `filepath`   
  Path of the gem file.

## Example

```js
const {$status, filename, filepath} = await nikita.tools.rubygems.fetch({
  name: 'json',
  version: '2.1.0',
  cwd: '/tmp/my_gems'
})
console.info(`Gem fetched: ${$status}`)
```

## Implementation

We do not support gem returning specification with binary strings because we
couldn't find any suitable parser on NPM.
