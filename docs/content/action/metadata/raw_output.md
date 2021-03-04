---
navtitle: raw_output
related:
- /action/metadata/raw
- /action/metadata/raw_input
---

# Metadata "raw_output"

The `raw_output` metadata prevents any modification to the value returned by an action. The value is returned as it is returned by the [action handler](/current/action/handler).

* Type: `boolean`
* Default: `false`

For example, the object returned by the handler is not merged with the object containing the `status` and `log` properties accomplishing [the default behavior](/current/action/handler#return):

```js
nikita
.call(async function() {
  // Get the output
  const output = await this.call({
    metadata: {
      // highlight-next-line
      raw_output: true
    }
  }, function() {
    return {who: 'Nikita'}
  })
  // Print the output
  console.log(output) // {who: 'Nikita'}
})
```
