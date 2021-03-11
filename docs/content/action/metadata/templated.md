---
navtitle: templated
---

# Metadata "templated"

Nikita provides templating in configuration properties using the [Handlebars](https://handlebarsjs.com/) templating engine. It traverses properties recursively and uses the same self-referenced object as a context. The `templated` metadata enables or disables templating which is enabled by default.

* Type: `boolean`

## Usage

The metadata value is propagated to all child actions. Pass `false` to disable templating:

```js
nikita
// Call an action with templating (by default)
.call({
  key_1: 'value 1',
  // highlight-next-line
  key_2: 'value 2 and {{config.key_1}}',
}, function({config}) {
  // Print config
  console.info(config) // { key_1: 'value 1', key_2: 'value 2 and value 1' }
})
// Call an action without templating 
.call({
  key_1: 'value 1',
  // highlight-range{1-2}
  key_2: 'value 2 and {{config.key_1}}',
  $templated: false
}, function({config}) {
  // Print config
  console.info(config) // { key_1: 'value 1', key_2: 'value 2 and {{config.key_1}}' }
  // Call a child action
  this.call({
    key_1: 'value 1',
    // highlight-next-line
    key_2: 'value 2 and {{config.key_1}}',
  }, function({config}) {
    // Print config
    console.log(config) // { key_1: 'value 1', key_2: 'value 2 and {{config.key_1}}' }
  })
})
```
