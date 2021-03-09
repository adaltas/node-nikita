---
navtitle: Output
sort: 3
---

# Action output

The action output is the value returned by the [action handler](/current/action/handler) and available inside a [promise](/current/usages/promise).

## Usage

The action output is returned when its [promise](/current/usages/promise) is fulfilled, thus, it is accessed using the [`async`/`await` operators](https://nodejs.dev/learn/modern-asynchronous-javascript-with-async-and-await).

```js
nikita
// highlight-next-line
.call(async function() {
  // Access the action output
  // highlight-next-line
  const {who} = await this.call(({tools: {log}}) => {
    return {who: 'Nikita'}
  })
  // Print the output
  console.info(who)
  // Output the value "Nikita"
})
```

## Plugin enrichment

This returned value is eventualy modified by plugins.

The `@nikitajs/core/lib/plugins/status` plugin enriches the value with a `$status` property when an object literal is returned and converts the value `true` to `{ $status: true }` when a boolean value is returned. The `@nikitajs/core/lib/plugins/output_log` plugin returns the logs emitted inside the action.

Below is the description of those properties when the returned value is an object literal:

- [`$status`](/current/action/output/status)   
  A boolean value of the action status.
- [`$log`](/current/action/output/log)   
  An array of objects with [logging](/current/usages/logging_debugging) information of the action execution.

In case the returned value shall be preserved and untouched, the [`raw_output` metadata](/current/metadata/raw_output) instructs Nikita to not alter the value returned by the handler.
