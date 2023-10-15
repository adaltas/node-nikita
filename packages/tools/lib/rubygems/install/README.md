
# `nikita.tools.rubygems.install`

Install a Ruby gem.

Ruby gems package a ruby library with a common layout. Inside, gems contains the 
following files:

- Code (including tests and supporting utilities)
- Documentation
- gemspec

## Example

Install a gem from its name and version:

```js
const {$status} = await nikita.tools.rubygems.install({
  name: 'json',
  version: '2.1.0',
})
console.info(`Gem installed: ${$status}`)
```

Install a gem from a local file:

```js
const {$status} = await nikita.tools.rubygems.install({
  source: '/path/to/json-2.1.0.gem'
})
console.info(`Gem installed: ${$status}`)
```

Install gems from a glob expression:

```js
const {$status} = await nikita.tools.rubygems.install({
  source: '/path/to/*.gem',
})
console.info(`Gem installed: ${$status}`)
```
